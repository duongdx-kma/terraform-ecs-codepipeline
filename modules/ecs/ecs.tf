# ECS - cluster
resource "aws_ecs_cluster" "terraform-cluster" {
  name               = "terraform-cluster"
  tags = merge({Name = "${var.env}-terraform-cluster"}, var.tags)
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.terraform-cluster.name
  capacity_providers = ["FARGATE"]
}

# ECS - Service
resource "aws_ecs_service" "backend-service" {
  name             = "backend-${var.env}" # same ECR image name
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  cluster          = aws_ecs_cluster.terraform-cluster.id
  task_definition  = aws_ecs_task_definition.terraform-task-definition.arn

  lifecycle {
    ignore_changes = [desired_count]
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets = var.private-subnet-ids
    security_groups = var.private-sg-ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target-group-arn
    container_name   = "backend-app"
    container_port   = 8088
  }
}

// https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/networking-connecting-services.html
// https://medium.com/@mr.mornesnyman/streamline-dns-record-management-for-ecs-services-with-terraform-aws-service-discovery-and-aws-a5fa32b3b8a4
# ECS - task definition
resource "aws_ecs_task_definition" "terraform-task-definition" {
  family                   = "backend-${var.env}" # same ECR image name
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.task-execution-role-arn # role arn starting task
  task_role_arn            = var.task-role-arn # role arn for task's Application running
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name      = "backend-app"
      image     = var.ecr-repository-url
      essential = true
      portMappings = [
        {
          containerPort = 8088
          hostPort      = 8088
        }
      ],
      logConfiguration: {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/fargate/service/backend-${var.env}",
          "awslogs-region": var.aws_region,
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ])

  tags = merge({Name = "${var.env}-terraform-task-definition"}, var.tags)
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/fargate/service/backend-${var.env}"
  retention_in_days = var.logs-retention-in-days
  tags              = var.tags
}