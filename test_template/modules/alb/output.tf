#--------------------------------------------------
# ALB Public
#--------------------------------------------------
output "alb_public" {
  description = "ALB Public"
  value       = aws_lb.alb_public
}

output "target_group_public" {
  description = "Target Group Public"
  value       = aws_lb_target_group.target_group_gateway
}