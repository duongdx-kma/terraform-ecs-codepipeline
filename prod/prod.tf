module "ecr" {
  source     = "../modules/ecr"
  aws_region = var.aws_region
  tags       = var.tags
  env        = var.env
}

# VPC module
module "vpc" {
  source               = "../modules/vpc"
  env                  = var.env
  aws_region           = var.aws_region
  tags                 = var.tags
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
  vpc_id     = module.vpc.vpc_id
  aws_region = var.aws_region

  alb-ingress = [
    {
      from_port : var.lb-listen-port
      to_port : var.lb-listen-port
      protocol : "TCP"
      cidr_blocks : ["0.0.0.0/0"]
    },
    {
      from_port : 80
      to_port : 80
      protocol : "TCP"
      cidr_blocks : ["0.0.0.0/0"]
    }
  ]

  batch-ingress = [
    {
      from_port : 22 // jenkins
      to_port : 22 // jenkins
      protocol : "TCP"
      cidr_blocks : ["0.0.0.0/0"]
    },
    {
      from_port : 8080 // jenkins
      to_port : 8080 // jenkins
      protocol : "TCP"
      cidr_blocks : ["0.0.0.0/0"]
    },
    {
      from_port : 80
      to_port : 80
      protocol : "TCP"
      cidr_blocks : ["0.0.0.0/0"]
    }
  ]

  instance-ingress = [
    {
      from_port : var.instance-port
      to_port : var.instance-port
      protocol : "TCP"
    }
  ]

  rds-ingress = [
    {
      from_port : "3306"
      to_port : "3306"
      protocol : "TCP"
    }
  ]

  endpoint-ingress = [
    {
      from_port : "443"
      to_port : "443"
      protocol : "TCP"
    }
  ]
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
  certificate_arn       = module.api_acm.api_acm_arn
}

module "policies" {
  source                   = "../modules/iam-policies"
  alb-arn                  = module.alb.lb-arn
  task-role-name           = module.roles.ecs-task-role.name
  task-execution-role-name = module.roles.ecs-task-execution-role.name
}

module "ecs" {
  source                  = "../modules/ecs"
  env                     = var.env
  tags                    = var.tags
  aws_region              = var.aws_region
  task-role-arn           = module.roles.ecs-task-role.arn
  private-sg-ids          = [module.security-groups.instance-sg-id]
  ecr-repository-url      = module.ecr.ecr-output
  target-group-arn        = module.alb.blue_target_group_arn # v1 - blue
  private-subnet-ids      = slice(module.vpc.private_subnets, 0, 2) // private-subnet-a, private-subnet-b
  task-execution-role-arn = module.roles.ecs-task-execution-role.arn
}

module "auto-scaling" {
  source           = "../modules/auto-scaling"
  ecs_cluster_name = module.ecs.ecs_cluster.name
  ecs_service_name = module.ecs.ecs_service.name
}

module "codebuild" {
  source              = "../modules/code-build"
  tags                = var.tags
  aws_region          = var.aws_region
  env                 = var.env
  ecr_repository_name = module.ecr.ecr_name
  rds_endpoint        = module.rds.mysql-rds-address
  username            = var.username
  db_name             = var.db_name
  db_port             = "3306"
  app_port            = var.instance-port
  app_env             = "prod"
  db_driver           = module.rds.mysql_engine_name
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
  github_username                  = var.github_username
  github_repo                      = var.github_repo
  branch_name                      = var.branch_name
  application_name                 = "terraform-ecs-codepipeline"
}

module "route53" {
  source          = "../modules/route53"
  elb_dns_name    = module.alb.lb-dns
  elb_zone_id     = module.alb.lb-zone-id
  hosted_zone_id  = var.hosted_zone_id
  api_domain_name = var.api_domain_name
}

module api_acm {
  source          = "../modules/api-acm"
  hosted_zone_id  = var.hosted_zone_id
  api_domain_name = var.api_domain_name
}

module batch_instance {
  source              = "../modules/jenkins"
  path_to_public_key  = var.path_to_public_key
  batch_instance_ami  = var.batch_instance_ami
  batch_instance_type = var.batch_instance_type
  batch_subnet_id     = element(module.vpc.public_subnets, 0)
  instance_user_name  = var.instance_user_name
  env                 = var.env
  tags                = var.tags
  batch_sg_ids        = [module.security-groups.batch-sg-id]
  use_data_file       = "user-data.sh"
  hosted_zone_id      = var.hosted_zone_id
  batch_domain_name   = "batch.duongdx.com"
}

# cloudfront ACM
module cloudfront_acm {
  source    = "../modules/cloudfront-acm"
  providers = {
    aws = aws.us-east-1
  }
  route53_cert_dns = module.frontend.route53_cert_dns
  params           = {
    admin = {
      bucket_name    = var.frontend_bucket_name
      domain_name    = var.frontend_domain_name
      hosted_zone_id = var.frontend_hosted_zone_id
    }
  }
}

// frontend
module frontend {
  source = "../modules/frontend"
  tags   = var.tags
  env    = var.env
  acm    = module.cloudfront_acm.acm_output

  params = {
    admin = {
      bucket_name    = var.frontend_bucket_name
      domain_name    = var.frontend_domain_name
      hosted_zone_id = var.frontend_hosted_zone_id
    }
  }
}