resource "aws_cloudwatch_log_metric_filter" "error_metric_filter" {
  name           = "ErrorMetricFilter"
  log_group_name = var.ecs_instance_log_group_name
  pattern        = "ERROR"
  metric_transformation {
    name      = "ErrorCount"
    namespace = "ECS-Custom"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "error-exceeded" {
  alarm_name          = "error-exceeded"
  metric_name         = aws_cloudwatch_log_metric_filter.error_metric_filter.name
  threshold           = 10
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = "60"
  namespace           = "ECS-Custom"
}

#Reinitialized existing Git repository in /home/gitlab-runner/builds/3vCWHzkoa/0/digidinosvn/speeed/speeed-api/.git/
#fatal: unable to access 'https://gitlab.com/digidinosvn/speeed/speeed-api.git/': SSL certificate problem: unable to get local issuer certificate
#Cleaning up project directory and file based variables
#}