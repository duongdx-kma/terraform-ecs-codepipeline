#resource "aws_cloudwatch_metric_alarm" "error-exceeded" {
#  alarm_name          = "demo-ecs-alarm"
#  comparison_operator = "GreaterThanUpperThreshold"
#  evaluation_periods  = 1
#  threshold           = 1
#  alarm_actions       = [aws_codedeploy_app.ecs-deploy.arn]
#  alarm_description   = "code deploy reverse deployment"
#
#  metric_query {
#    id = "ecs-metric"
#
#    metric {
#      metric_name = "MemoryUtilization"
#      namespace   = "AWS/ECS"
#      period      = 120
#      stat        = "Sum"
#      unit        = "Count"
#
#      dimensions = {
#        ClusterName = var.ecs_cluster_name
#        ServiceName = var.ecs_cluster_name
#      }
#    }
#  }
#}

#Reinitialized existing Git repository in /home/gitlab-runner/builds/3vCWHzkoa/0/digidinosvn/speeed/speeed-api/.git/
#fatal: unable to access 'https://gitlab.com/digidinosvn/speeed/speeed-api.git/': SSL certificate problem: unable to get local issuer certificate
#Cleaning up project directory and file based variables
#}