output "instance_id" {
  description = "IDs of the web stack EC2 instances."
  value       = module.ec2_instance[*].id
}

output "instance_private_ip" {
  description = "Private IP addresses of the web stack instances."
  value       = module.ec2_instance[*].private_ip
}

output "instance_public_ip" {
  description = "Public IP addresses of the Git server instances when deployed in public subnets."
  value       = module.ec2_instance[*].public_ip
}

output "security_group_id" {
  description = "Security group ID attached to the web stack instance."
  value       = aws_security_group.git_server.id
}

output "key_pair_name" {
  description = "EC2 key pair name used by the web stack instance."
  value       = var.create_key_pair ? aws_key_pair.git_server[0].key_name : var.key_name
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs in the VPC."
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "Public subnet IDs in the VPC."
  value       = module.vpc.public_subnets
}
