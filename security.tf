resource "aws_security_group" "git_server" {
  name_prefix = "${var.project_name}-"
  description = "Security group for the single EC2 web stack"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = toset(var.allowed_ssh_cidr_blocks)

  security_group_id = aws_security_group.git_server.id
  description       = "Allow SSH from trusted CIDR blocks"
  cidr_ipv4         = each.value
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each = var.install_nginx && var.expose_nginx_http ? toset(var.allowed_service_cidr_blocks) : toset([])

  security_group_id = aws_security_group.git_server.id
  description       = "Allow HTTP to Nginx"
  cidr_ipv4         = each.value
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = var.install_nginx && var.expose_nginx_https ? toset(var.allowed_service_cidr_blocks) : toset([])

  security_group_id = aws_security_group.git_server.id
  description       = "Allow HTTPS to Nginx"
  cidr_ipv4         = each.value
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "mysql" {
  for_each = var.install_mysql && var.expose_mysql ? toset(var.allowed_mysql_cidr_blocks) : toset([])

  security_group_id = aws_security_group.git_server.id
  description       = "Allow MySQL-compatible database access"
  cidr_ipv4         = each.value
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_ingress_rule" "application_ports" {
  for_each = local.application_ingress_rules

  security_group_id = aws_security_group.git_server.id
  description       = "Allow explicit application port ${each.value.port}"
  cidr_ipv4         = each.value.cidr
  from_port         = each.value.port
  ip_protocol       = "tcp"
  to_port           = each.value.port
}

resource "aws_vpc_security_group_ingress_rule" "smtp_submission" {
  for_each = toset(var.allowed_application_cidr_blocks)

  security_group_id = aws_security_group.git_server.id
  description       = "Allow SMTP submission"
  cidr_ipv4         = each.value
  from_port         = 587
  ip_protocol       = "tcp"
  to_port           = 587
}

resource "aws_vpc_security_group_ingress_rule" "application_port_range" {
  for_each = toset(var.allowed_application_cidr_blocks)

  security_group_id = aws_security_group.git_server.id
  description       = "Allow application port range 3000-11000"
  cidr_ipv4         = each.value
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 11000
}

resource "aws_vpc_security_group_ingress_rule" "wireguard" {
  for_each = toset(var.allowed_application_cidr_blocks)

  security_group_id = aws_security_group.git_server.id
  description       = "Allow WireGuard"
  cidr_ipv4         = each.value
  from_port         = 51820
  ip_protocol       = "udp"
  to_port           = 51820
}

resource "aws_vpc_security_group_egress_rule" "tcp" {
  for_each = local.tcp_egress_rules

  security_group_id = aws_security_group.git_server.id
  description       = "Allow outbound TCP ${each.value.port}"
  cidr_ipv4         = each.value.cidr
  from_port         = each.value.port
  ip_protocol       = "tcp"
  to_port           = each.value.port
}

resource "aws_vpc_security_group_egress_rule" "dns_udp" {
  for_each = toset(var.allowed_egress_cidr_blocks)

  security_group_id = aws_security_group.git_server.id
  description       = "Allow outbound DNS over UDP"
  cidr_ipv4         = each.value
  from_port         = 53
  ip_protocol       = "udp"
  to_port           = 53
}

resource "aws_vpc_security_group_egress_rule" "dns_tcp" {
  for_each = toset(var.allowed_egress_cidr_blocks)

  security_group_id = aws_security_group.git_server.id
  description       = "Allow outbound DNS over TCP"
  cidr_ipv4         = each.value
  from_port         = 53
  ip_protocol       = "tcp"
  to_port           = 53
}
