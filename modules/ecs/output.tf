output "ecs_cluster" {
  value = aws_ecs_cluster.terraform-cluster
}

output "ecs_service" {
  value = aws_ecs_service.backend-service
}

output "ecs_instance_log_group_name" {
  value = aws_cloudwatch_log_group.logs.name
}