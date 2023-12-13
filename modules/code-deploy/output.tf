output "codedeploy_app_name" {
  value = aws_codedeploy_app.ecs-deploy.name
}

output "codedeploy_deployment_group_name" {
  value = aws_codedeploy_deployment_group.blue_green_deployment.deployment_group_name
}