# Root outputs showing cross-module references

# ========================
# VPC Module Outputs
# ========================

output "vpc_id" {
  description = "VPC ID from VPC module"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR from VPC module"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs from VPC module"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs from VPC module"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_id" {
  description = "NAT Gateway ID from VPC module"
  value       = module.vpc.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway public IP from VPC module"
  value       = module.vpc.nat_gateway_public_ip
}

# ========================
# Security Module Outputs
# ========================

output "web_security_group_id" {
  description = "Web security group ID from Security module"
  value       = module.security.web_sg_id
}

output "db_security_group_id" {
  description = "Database security group ID from Security module"
  value       = module.security.db_sg_id
}

# ========================
# Compute Module Outputs
# ========================

output "instance_id" {
  description = "EC2 instance ID from Compute module"
  value       = module.compute.instance_id
}

output "instance_public_ip" {
  description = "Public IP of the instance (via Elastic IP)"
  value       = module.compute.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the instance"
  value       = module.compute.private_ip
}

output "instance_availability_zone" {
  description = "AZ where instance is running"
  value       = module.compute.availability_zone
}

# ========================
# Cross-Module Integration Examples
# ========================

output "architecture_summary" {
  description = "Summary of deployed architecture with cross-module references"
  value = {
    vpc_configuration = {
      vpc_id                  = module.vpc.vpc_id
      cidr_block              = module.vpc.vpc_cidr
      public_subnets          = module.vpc.public_subnet_ids
      private_subnets        = module.vpc.private_subnet_ids
    }
    security_groups = {
      web_sg_id  = module.security.web_sg_id
      database_sg_id = module.security.db_sg_id
    }
    compute = {
      instance_id     = module.compute.instance_id
      public_ip       = module.compute.public_ip
      private_ip      = module.compute.private_ip
      subnet_id       = module.vpc.public_subnet_ids[0]
      security_groups = module.compute.security_groups
    }
  }
}

output "connection_details" {
  description = "Connection details for the instance"
  value = {
    ssh_command = var.key_name != null ? "ssh -i /path/to/key.pem ec2-user@${module.compute.public_ip}" : "SSH Key not configured"
    http_url    = "http://${module.compute.public_ip}/"
    https_url   = "https://${module.compute.public_ip}/"
  }
}

# ========================
# Module References Documentation
# ========================

output "module_cross_references" {
  description = "Documentation of how modules reference each other"
  value = {
    "Security Module references VPC" = "module.security.source -> module.vpc.vpc_id"
    "Compute Module references VPC" = "module.compute.source -> module.vpc.public_subnet_ids[0]"
    "Compute Module references Security" = "module.compute.source -> module.security.web_sg_id"
    "Root Config passes outputs" = "Example: module.security uses module.vpc.vpc_id as input"
  }
}
