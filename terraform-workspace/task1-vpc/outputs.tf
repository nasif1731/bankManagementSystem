# Task 1: Custom VPC with Subnetting and NAT Gateway
# Output Definitions

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_1_id" {
  description = "ID of public subnet 1 (AZ 1)"
  value       = aws_subnet.public_1.id
}

output "public_subnet_1_cidr" {
  description = "CIDR block of public subnet 1"
  value       = aws_subnet.public_1.cidr_block
}

output "public_subnet_1_az" {
  description = "Availability Zone of public subnet 1"
  value       = aws_subnet.public_1.availability_zone
}

output "public_subnet_2_id" {
  description = "ID of public subnet 2 (AZ 2)"
  value       = aws_subnet.public_2.id
}

output "public_subnet_2_cidr" {
  description = "CIDR block of public subnet 2"
  value       = aws_subnet.public_2.cidr_block
}

output "public_subnet_2_az" {
  description = "Availability Zone of public subnet 2"
  value       = aws_subnet.public_2.availability_zone
}

output "private_subnet_1_id" {
  description = "ID of private subnet 1 (AZ 1)"
  value       = aws_subnet.private_1.id
}

output "private_subnet_1_cidr" {
  description = "CIDR block of private subnet 1"
  value       = aws_subnet.private_1.cidr_block
}

output "private_subnet_1_az" {
  description = "Availability Zone of private subnet 1"
  value       = aws_subnet.private_1.availability_zone
}

output "private_subnet_2_id" {
  description = "ID of private subnet 2 (AZ 2)"
  value       = aws_subnet.private_2.id
}

output "private_subnet_2_cidr" {
  description = "CIDR block of private subnet 2"
  value       = aws_subnet.private_2.cidr_block
}

output "private_subnet_2_az" {
  description = "Availability Zone of private subnet 2"
  value       = aws_subnet.private_2.availability_zone
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_public_ip" {
  description = "Elastic IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "nat_gateway_allocation_id" {
  description = "Allocation ID of the Elastic IP for NAT Gateway"
  value       = aws_eip.nat.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

output "summary" {
  description = "Summary of all created resources"
  value = {
    vpc_name                = aws_vpc.main.tags.Name
    vpc_id                  = aws_vpc.main.id
    vpc_cidr                = aws_vpc.main.cidr_block
    dns_support_enabled     = aws_vpc.main.enable_dns_support
    dns_hostnames_enabled   = aws_vpc.main.enable_dns_hostnames
    public_subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    private_subnets         = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    internet_gateway_id     = aws_internet_gateway.main.id
    nat_gateway_id          = aws_nat_gateway.main.id
    nat_gateway_public_ip   = aws_eip.nat.public_ip
    public_route_table      = aws_route_table.public.id
    private_route_table     = aws_route_table.private.id
  }
}
