module "ecr" {
  source     = "../modules/ecr"
  aws_region = var.aws_region
  tags       = var.tags
  env        = var.env
}

# VPC module
module "vpc" {
  source     = "../modules/vpc"
  env        = var.env
  aws_region = var.aws_region
  tags       = var.tags
  azs                  = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  private_subnet_cidrs = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
}

module "vpc-endpoint" {
  source                     = "../modules/vpc-endpoint"
  env                        = var.env
  tags                       = var.tags
  vpc_id                     = module.vpc.vpc_id
  aws_region                 = var.aws_region
  vpc_endpoint_sg_ids        = [module.security-groups.endpoint-sg-id]
  vpc_endpoint_subnet_ids    = slice(module.vpc.private_subnets, 0, 2) // private-subnet-a, private-subnet-b
  vpc-private-route-table-id = [module.vpc.private-route-table-id]
}

# Security group module
module "security-groups" {
  source     = "../modules/security-groups"
  env        = var.env
  tags       = var.tags
  vpc_id     =  module.vpc.vpc_id
  aws_region = var.aws_region

  alb-ingress = [
    {
      from_port: var.lb-listen-port
      to_port: var.lb-listen-port
      protocol: "TCP"
      cidr_blocks: ["0.0.0.0/0"]
    },
    {
      from_port: 80
      to_port: 80
      protocol: "TCP"
      cidr_blocks: ["0.0.0.0/0"]
    }
  ]

  instance-ingress = [{
    from_port: var.instance-port
    to_port: var.instance-port
    protocol: "TCP"
  }]

  rds-ingress = [{
    from_port: "3306"
    to_port: "3306"
    protocol: "TCP"
  }]

  endpoint-ingress = [{
    from_port: "443"
    to_port: "443"
    protocol: "TCP"
  }]
}

module "roles" {
  source     = "../modules/iam-roles"
  env        = var.env
  tags       = var.tags
  aws_region = var.aws_region
}

module "rds" {
  source                 = "../modules/rds"
  username               = var.username
  db_name                = var.db_name
  subnet_ids             = module.vpc.public_subnets
  rds_security_group_ids = [module.security-groups.rds-sg-id]
  rds_credentials_key    = "rds_credentials_prod"
}

module "alb" {
  source                = "../modules/alb"
  env                   = var.env
  tags                  = var.tags
  vpc_id                = module.vpc.vpc_id
  alb-sg-ids            = [module.security-groups.alb-sg-id]
  lb-listen-port        = var.lb-listen-port
  lb-listen-protocol    = var.lb-listen-protocol
  health-check-count    = 3
  alb-public-subnet-ids = slice(module.vpc.public_subnets, 0, 2) // public-subnet-a, public-subnet-b
  certificate_arn       = aws_acm_certificate.certificate.arn
}

module "policies" {
  source                     = "../modules/iam-policies"
  alb-arn                    = module.alb.lb-arn
  task-role-name             = module.roles.ecs-task-role.name
  task-execution-role-name   = module.roles.ecs-task-execution-role.name
}

module "ecs" {
  source                  = "../modules/ecs"
  env                     = var.env
  tags                    = var.tags
  aws_region              = var.aws_region
  task-role-arn           = module.roles.ecs-task-role.arn
  private-sg-ids          = [module.security-groups.instance-sg-id]
  repository-url          = "${module.ecr.ecr-output}:${var.commit-id}"
  target-group-arn        = module.alb.blue_target_group_arn # v1 - blue
  private-subnet-ids      = slice(module.vpc.private_subnets, 0, 2) // private-subnet-a, private-subnet-b
  task-execution-role-arn = module.roles.ecs-task-execution-role.arn
}

module "auto-scaling" {
  source      = "../modules/auto-scaling"
  ecs_cluster_name = module.ecs.ecs_cluster.name
  ecs_service_name = module.ecs.ecs_service.name
}

module "code_commit" {
  source = "../modules/code-commit"
}

module "codebuild" {
  source = "../modules/code-build"
  tags = var.tags
  aws_region = var.aws_region
  env = var.env
  ecr_repository_name = module.ecr.ecr_name
  rds_endpoint        = module.rds.mysql-rds-address
  username            = var.username
  db_name             = var.db_name
  db_port             = "3306"
  app_port            = var.instance-port
  app_env             = "production"
  secret_manager_name = module.rds.secret_manager_name
}

module "codedeploy" {
  source                      = "../modules/code-deploy"
  tags                        = var.tags
  env                         = var.env
  ecs_cluster_name            = module.ecs.ecs_cluster.name
  ecs_service_name            = module.ecs.ecs_service.name
  listener_arn                = module.alb.listener_arn
  blue_target_group_name      = module.alb.blue_target_group_name
  green_target_group_name     = module.alb.green_target_group_name
  ecs_instance_log_group_name = module.ecs.ecs_instance_log_group_name
}

module "codepipeline" {
  source                           = "../modules/code-pipeline"
  tags                             = var.tags
  env                              = var.env
  codedeploy_app_name              = module.codedeploy.codedeploy_app_name
  codedeploy_deployment_group_name = module.codedeploy.codedeploy_deployment_group_name
  codebuild_project_name           = module.codebuild.codebuild_project_name
  codebuild_project_arn            = module.codebuild.codebuild_project_arn
  codecommit_repo_name             = module.code_commit.codecommit_repo_name
  codecommit_repo_arn              = module.code_commit.codecommit_repo_arn
  branch_name                      = "master"
  application_name                 = "terraform-ecs-codepipeline"
}


module "route53" {
  source         = "../modules/route53"
  elb-dns-name   = module.alb.lb-dns
  elb-zone-id    = module.alb.lb-zone-id
  hosted_zone_id = var.hosted_zone_id
}

# Create an ACM Certificate
resource "aws_acm_certificate" "certificate" {
  domain_name       = var.root_domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_dns" {
  allow_overwrite = true
  name            =  tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_type
  zone_id         = var.hosted_zone_id
  ttl = 60
}

resource "aws_acm_certificate_validation" "hello_cert_validate" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.cert_dns.fqdn]
}
