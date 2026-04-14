# Task 4: Auto Scaling Group with CloudWatch Alarms
# Output values for ASG, launch template, and CloudWatch alarms

output "vpc" {
  description = "VPC details"
  value = {
    id            = aws_vpc.task4.id
    cidr_block    = aws_vpc.task4.cidr_block
  }
}

output "subnets" {
  description = "Public subnets for ASG"
  value = {
    az1_id = aws_subnet.public_az1.id
    az2_id = aws_subnet.public_az2.id
  }
}

output "security_group" {
  description = "Security group for ASG instances"
  value = {
    id   = aws_security_group.web.id
    name = aws_security_group.web.name
  }
}

output "ssh_key_pair" {
  description = "SSH key pair details"
  value = {
    name              = aws_key_pair.task4.key_name
    private_key_file  = local_file.private_key.filename
  }
}

output "launch_template" {
  description = "Launch template details"
  value = {
    id      = aws_launch_template.web.id
    name    = aws_launch_template.web.name
    version = aws_launch_template.web.latest_version
  }
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.web.id
}

output "launch_template_latest_version" {
  description = "Latest version of launch template"
  value       = aws_launch_template.web.latest_version
}

output "autoscaling_group" {
  description = "Auto Scaling Group details"
  value = {
    name              = aws_autoscaling_group.web.name
    min_size          = aws_autoscaling_group.web.min_size
    max_size          = aws_autoscaling_group.web.max_size
    desired_capacity  = aws_autoscaling_group.web.desired_capacity
    vpc_zone_identifier = aws_autoscaling_group.web.vpc_zone_identifier
  }
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.web.name
}

output "autoscaling_group_arn" {
  description = "Auto Scaling Group ARN"
  value       = aws_autoscaling_group.web.arn
}

output "scale_out_policy" {
  description = "Scale-out policy details"
  value = {
    name       = aws_autoscaling_policy.scale_out.name
    arn        = aws_autoscaling_policy.scale_out.arn
    adjustment = aws_autoscaling_policy.scale_out.scaling_adjustment
  }
}

output "scale_in_policy" {
  description = "Scale-in policy details"
  value = {
    name       = aws_autoscaling_policy.scale_in.name
    arn        = aws_autoscaling_policy.scale_in.arn
    adjustment = aws_autoscaling_policy.scale_in.scaling_adjustment
  }
}

output "cpu_high_alarm" {
  description = "CloudWatch alarm for high CPU (scale-out)"
  value = {
    alarm_name = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
    arn        = aws_cloudwatch_metric_alarm.cpu_high.arn
    threshold  = aws_cloudwatch_metric_alarm.cpu_high.threshold
  }
}

output "cpu_low_alarm" {
  description = "CloudWatch alarm for low CPU (scale-in)"
  value = {
    alarm_name = aws_cloudwatch_metric_alarm.cpu_low.alarm_name
    arn        = aws_cloudwatch_metric_alarm.cpu_low.arn
    threshold  = aws_cloudwatch_metric_alarm.cpu_low.threshold
  }
}

output "stress_ng_command" {
  description = "Command to generate CPU load with stress-ng"
  value       = "stress-ng --cpu 1 --cpu-load 100 --timeout 300s"
}

output "monitor_cpu_command" {
  description = "AWS CLI command to monitor CPU utilization"
  value       = "aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --dimensions Name=AutoScalingGroupName,Value=${aws_autoscaling_group.web.name} --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%S) --end-time $(date -u +%Y-%m-%dT%H:%M:%S) --period 60 --statistics Average"
}

output "view_asg_activity_command" {
  description = "AWS CLI command to view ASG activity history"
  value       = "aws autoscaling describe-scaling-activities --auto-scaling-group-name ${aws_autoscaling_group.web.name}"
}

output "ssh_command" {
  description = "SSH command to connect to ASG instance"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@<instance-ip>"
}
