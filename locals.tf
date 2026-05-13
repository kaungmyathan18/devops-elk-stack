locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }

  application_ingress_rules = {
    for rule in setproduct(var.allowed_application_cidr_blocks, toset(var.allowed_application_ports)) :
    "${rule[0]}-${rule[1]}" => {
      cidr = rule[0]
      port = rule[1]
    }
  }

  tcp_egress_rules = {
    for rule in setproduct(var.allowed_egress_cidr_blocks, toset(var.allowed_egress_tcp_ports)) :
    "${rule[0]}-${rule[1]}" => {
      cidr = rule[0]
      port = rule[1]
    }
  }
}
