resource "aws_cloudwatch_metric_alarm" "error-exceeded" {
  alarm_name          = "demo-ecs-alarm"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 1
  threshold_metric_id = "ecs"
  alarm_actions       = [aws_codedeploy_app.ecs-deploy.arn]
  alarm_description   = "code deploy reverse deployment"

  metric_query {
    id = "ecs"

    metric {
      metric_name = "MemoryUtilization"
      namespace   = "AWS/ECS"
      period      = 120
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_cluster_name
      }
    }
  }
}