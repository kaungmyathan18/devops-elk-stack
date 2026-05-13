module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name                        = "${var.project_name}-${["ELK", "Server"][count.index]}"
  count                       = 2
  ami                         = coalesce(var.ami_id, data.aws_ami.amazon_linux_2023.id)
  instance_type               = var.instance_type
  key_name                    = var.create_key_pair ? aws_key_pair.git_server[0].key_name : var.key_name
  monitoring                  = var.enable_detailed_monitoring
  subnet_id                   = var.instance_subnet_type == "private" ? module.vpc.private_subnets[0] : module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.git_server.id]
  associate_public_ip_address = var.instance_subnet_type == "public"
  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    install_nginx                     = var.install_nginx
    install_mysql                     = var.install_mysql
    install_nodejs                    = var.install_nodejs
    nodejs_version                    = var.nodejs_version
    mysql_package_name                = var.mysql_package_name == null ? "" : var.mysql_package_name
    enable_security_tools             = var.enable_security_tools
    enable_automatic_security_updates = var.enable_automatic_security_updates
    enable_host_firewall              = var.enable_host_firewall
    application_ports                 = join(",", var.allowed_application_ports)
  })

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = 1
  }

  root_block_device = [{
    delete_on_termination = true
    encrypted             = var.root_volume_encrypted
    kms_key_id            = var.root_volume_kms_key_id
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
  }]

  create_iam_instance_profile = var.enable_ssm
  iam_role_description        = "IAM role for ${var.project_name} SSM Session Manager access"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = local.common_tags
}
