# Task 5: Elastic Load Balancer with Health Checks
# Output values for ALB, target groups, and related resources

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "alb_url" {
  description = "URL to access the load balancer"
  value       = "http://${aws_lb.main.dns_name}"
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.main.arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.main.name
}

output "alb_security_group" {
  description = "ALB security group details"
  value = {
    id   = aws_security_group.alb.id
    name = aws_security_group.alb.name
  }
}

output "task4_security_group" {
  description = "Task 4 EC2 security group details"
  value = {
    id = data.aws_security_groups.task4_web.ids[0]
  }
}

output "task4_vpc" {
  description = "Task 4 VPC details"
  value = {
    id         = data.aws_vpc.task4.id
    cidr_block = data.aws_vpc.task4.cidr_block
  }
}

output "task4_subnets" {
  description = "Task 4 public subnets"
  value       = data.aws_subnets.public.ids
}

output "task4_asg" {
  description = "Task 4 ASG details"
  value = {
    name             = data.aws_autoscaling_groups.task4.names[0]
    desired_capacity = var.asg_desired_capacity
  }
}

output "health_check_config" {
  description = "Target group health check configuration"
  value = {
    enabled              = var.health_check_enabled
    healthy_threshold    = var.health_check_healthy_threshold
    unhealthy_threshold  = var.health_check_unhealthy_threshold
    interval             = var.health_check_interval
    timeout              = var.health_check_timeout
    path                 = var.health_check_path
    matcher              = var.health_check_matcher
  }
}

output "load_balancer_url" {
  description = "URL for accessing the load balancer"
  value       = "http://${aws_lb.main.dns_name}/"
}

output "test_command" {
  description = "Command to test load balancer"
  value       = "curl http://${aws_lb.main.dns_name}/"
}

output "test_loop_command" {
  description = "Command to loop and test load balancer (shows round-robin)"
  value       = "for i in {1..10}; do curl -s http://${aws_lb.main.dns_name}/ | grep -o 'Instance ID:[^<]*'; done"
}

output "alb_listener" {
  description = "ALB listener details"
  value = {
    arn      = aws_lb_listener.main.arn
    port     = aws_lb_listener.main.port
    protocol = aws_lb_listener.main.protocol
  }
}
