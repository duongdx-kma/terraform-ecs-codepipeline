resource "aws_appautoscaling_target" "auto-scaling" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scaling-by-memory" {
  name               = "scaling-by-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.auto-scaling.resource_id
  scalable_dimension = aws_appautoscaling_target.auto-scaling.scalable_dimension
  service_namespace  = aws_appautoscaling_target.auto-scaling.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 60
  }
}

resource "aws_appautoscaling_policy" "scaling-by-cpu" {
  name               = "scaling-by-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.auto-scaling.resource_id
  scalable_dimension = aws_appautoscaling_target.auto-scaling.scalable_dimension
  service_namespace  = aws_appautoscaling_target.auto-scaling.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 60
  }
}

