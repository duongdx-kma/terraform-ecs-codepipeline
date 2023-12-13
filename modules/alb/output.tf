output "lb-dns" {
  value = aws_lb.main-alb.dns_name
}

output "lb-zone-id" {
  value = aws_lb.main-alb.zone_id
}

output "lb-arn" {
  value = aws_lb.main-alb.arn
}

output "listener_arn" {
  value = var.lb-listen-port == 443 ? aws_lb_listener.alb-listener["https"].arn :aws_lb_listener.alb-listener["http"].arn
}

output "blue_target_group_arn" {
  value = aws_lb_target_group.blue-target-group.arn
}

output "green_target_group_arn" {
  value = aws_lb_target_group.green-target-group.arn
}