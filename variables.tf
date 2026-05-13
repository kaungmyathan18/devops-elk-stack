variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Optional AWS CLI profile name to use for Terraform authentication."
  type        = string
  default     = null
}

variable "project_name" {
  description = "Name used for resource naming."
  type        = string
  default     = "single-ec2-web-stack"
}

variable "environment" {
  description = "Deployment environment tag."
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type for the web stack."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access. If create_key_pair is true, this is the AWS key pair name to create."
  type        = string
  default     = "user1"
}

variable "create_key_pair" {
  description = "Whether to create an AWS EC2 key pair from an existing local public SSH key."
  type        = bool
  default     = false
}

variable "public_key_path" {
  description = "Path to the local SSH public key to register when create_key_pair is true."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ami_id" {
  description = "Optional AMI ID. When null, the latest Amazon Linux 2023 AMI is used."
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 8

  validation {
    condition     = var.root_volume_size >= 8
    error_message = "root_volume_size must be at least 8 GiB."
  }
}

variable "root_volume_type" {
  description = "Root EBS volume type."
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Whether to encrypt the root EBS volume."
  type        = bool
  default     = true
}

variable "root_volume_kms_key_id" {
  description = "Optional KMS key ID or ARN for root EBS volume encryption. When null, the AWS managed EBS key is used."
  type        = string
  default     = null
}

variable "metadata_http_tokens" {
  description = "EC2 instance metadata token requirement. Use required to enforce IMDSv2."
  type        = string
  default     = "required"

  validation {
    condition     = contains(["optional", "required"], var.metadata_http_tokens)
    error_message = "metadata_http_tokens must be either optional or required."
  }
}

variable "enable_detailed_monitoring" {
  description = "Whether to enable detailed CloudWatch monitoring for the EC2 instance."
  type        = bool
  default     = false
}

variable "instance_subnet_type" {
  description = "Subnet tier for the EC2 instance. Use private for a private server, or public for direct internet access."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["private", "public"], var.instance_subnet_type)
    error_message = "instance_subnet_type must be either private or public."
  }
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed to reach SSH on port 22."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "allowed_service_cidr_blocks" {
  description = "CIDR blocks allowed to reach HTTP and HTTPS."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "allowed_application_cidr_blocks" {
  description = "CIDR blocks allowed to reach explicitly enabled application ports."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "allowed_application_ports" {
  description = "Additional TCP application ports to expose. Keep this empty for the lowest-cost hardened default."
  type        = list(number)
  default     = []

  validation {
    condition = alltrue([
      for port in var.allowed_application_ports : port >= 1 && port <= 65535
    ])
    error_message = "allowed_application_ports must contain valid TCP ports between 1 and 65535."
  }
}

variable "expose_nginx_http" {
  description = "Whether to create HTTP ingress rules when Nginx installation is enabled."
  type        = bool
  default     = true
}

variable "expose_nginx_https" {
  description = "Whether to create HTTPS ingress rules when Nginx installation is enabled."
  type        = bool
  default     = true
}

variable "expose_mysql" {
  description = "Whether to expose MySQL/MariaDB on port 3306. Defaults to false for security."
  type        = bool
  default     = false
}

variable "allowed_mysql_cidr_blocks" {
  description = "CIDR blocks allowed to reach MySQL/MariaDB when expose_mysql is true."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "allowed_egress_cidr_blocks" {
  description = "CIDR blocks allowed for outbound traffic."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_egress_tcp_ports" {
  description = "Outbound TCP ports allowed from the instance. Defaults support package installation, updates, SSM, and HTTPS downloads."
  type        = list(number)
  default     = [80, 443]

  validation {
    condition = alltrue([
      for port in var.allowed_egress_tcp_ports : port >= 1 && port <= 65535
    ])
    error_message = "allowed_egress_tcp_ports must contain valid TCP ports between 1 and 65535."
  }
}

variable "install_nginx" {
  description = "Whether cloud-init should install and enable Nginx."
  type        = bool
  default     = false
}

variable "install_mysql" {
  description = "Whether cloud-init should install and enable a MySQL-compatible database server."
  type        = bool
  default     = false
}

variable "install_nodejs" {
  description = "Whether cloud-init should install Node.js."
  type        = bool
  default     = false
}

variable "nodejs_version" {
  description = "Node.js version to install. Use latest for the newest upstream Linux x64 release, or a version such as 22.11.0 or v22.11.0."
  type        = string
  default     = "latest"
}

variable "mysql_package_name" {
  description = "Optional package name for MySQL-compatible server installation. Leave null to use distro-aware defaults."
  type        = string
  default     = null
}

variable "enable_security_tools" {
  description = "Whether cloud-init should install baseline host security tools such as fail2ban and auditd."
  type        = bool
  default     = true
}

variable "enable_automatic_security_updates" {
  description = "Whether cloud-init should enable automatic security updates where supported by the distribution."
  type        = bool
  default     = true
}

variable "enable_host_firewall" {
  description = "Whether cloud-init should enable a host firewall in addition to AWS security groups."
  type        = bool
  default     = false
}

variable "enable_ssm" {
  description = "Whether to attach an IAM instance profile for AWS Systems Manager Session Manager."
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones used by the VPC subnets."
  type        = list(string)
  default     = ["us-east-1a"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.101.0/24"]
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT gateways for private subnet outbound internet access."
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Whether to use a single shared NAT gateway when NAT is enabled."
  type        = bool
  default     = false
}
