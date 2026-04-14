output "web_sg_id" {
  description = "Web security group ID"
  value       = aws_security_group.web.id
}

output "web_sg_name" {
  description = "Web security group name"
  value       = aws_security_group.web.name
}

output "db_sg_id" {
  description = "Database security group ID"
  value       = aws_security_group.database.id
}

output "db_sg_name" {
  description = "Database security group name"
  value       = aws_security_group.database.name
}
