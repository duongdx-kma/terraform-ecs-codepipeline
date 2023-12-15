resource "aws_codedeploy_app" "ecs-deploy" {
  name             = "ecs-deploy"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "blue_green_deployment" {
  app_name = aws_codedeploy_app.ecs-deploy.name
  deployment_group_name  = "blue_green_deployment"
#  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM", "DEPLOYMENT_STOP_ON_REQUEST"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  alarm_configuration {
    alarms  = [aws_cloudwatch_metric_alarm.error-exceeded.alarm_name]
    enabled = true
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.listener_arn]
      }

      target_group {
        name = var.blue_target_group_name
      }

      target_group {
        name = var.green_target_group_name
      }
    }
  }

  tags = merge({Name = "${var.env}-ecs-codedeploy"}, var.tags)
}
