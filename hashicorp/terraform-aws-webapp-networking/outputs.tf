output "vpc_security_group_ids" {
  description = "IDs for security groups"
  value = aws_security_group.webapp_security_group.id
}

output "subnet_id" {
  description = "IDs for subnets"
  value = aws_subnet.app_subnet.id
}
