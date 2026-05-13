# Single EC2 Web Stack Terraform Template

This Terraform root module provisions a low-cost AWS EC2 instance in a VPC and can optionally bootstrap Nginx, a MySQL-compatible database server, and Node.js. Each component is controlled independently, so the same template can deploy all services, only selected services, or no pre-installed application software.

The default posture favors low cost and a conservative security baseline:

- One EC2 instance, defaulting to `t2.micro`
- No NAT gateway, load balancer, RDS database, or detailed monitoring by default
- Encrypted root EBS volume
- IMDSv2 required
- Minimal inbound rules
- Explicit application ports instead of broad port ranges
- Optional host security tooling through cloud-init

## Usage

Initialize and review before applying:

```sh
terraform init
terraform fmt
terraform validate
terraform plan
```

Deploy with no optional application services:

```hcl
project_name = "web-template-dev"

install_nginx  = false
install_mysql  = false
install_nodejs = false

allowed_ssh_cidr_blocks = ["203.0.113.10/32"]
```

Deploy all three components:

```hcl
project_name = "three-tier-starter"

install_nginx  = true
install_mysql  = true
install_nodejs = true

nodejs_version = "latest"

allowed_ssh_cidr_blocks     = ["203.0.113.10/32"]
allowed_service_cidr_blocks = ["0.0.0.0/0"]
allowed_application_ports   = [3000]
```

Keep MySQL private to the VPC:

```hcl
install_mysql = true
expose_mysql  = true

allowed_mysql_cidr_blocks = ["10.0.0.0/16"]
```

For a single-host three-tier starter, use Nginx as the web tier, Node.js on an explicit application port, and MySQL/MariaDB bound behind security group rules. For a production three-tier deployment, split these into separate resources later: public web tier, private app tier, and managed database tier.

## Linux Support

The bootstrap script detects common Linux package managers:

- `apt` for Debian and Ubuntu
- `dnf` and `yum` for RHEL, Fedora, CentOS, Amazon Linux, and related distributions
- `zypper` for openSUSE and SUSE

Nginx and security tools use distribution packages. Node.js uses upstream Linux binaries with SHA256 verification so `nodejs_version = "latest"` can install the latest available Node.js release across distributions. MySQL installation uses distro-aware defaults and may install MariaDB on distributions where MariaDB is the default MySQL-compatible server. Set `mysql_package_name` to force a specific package.

## Security Notes

AWS security groups are the primary network control. By default, SSH is limited to `10.0.0.0/16`, Nginx HTTP/HTTPS rules are only created when `install_nginx = true`, MySQL is not exposed unless `expose_mysql = true`, and extra application ports are only opened when listed in `allowed_application_ports`.

Host hardening options include:

- `enable_security_tools = true` to install tools such as `fail2ban` and `auditd` where available
- `enable_automatic_security_updates = true` for supported distributions
- `enable_host_firewall = true` to add a host firewall in addition to AWS security groups
- `enable_ssm = true` to attach an IAM instance profile for AWS Systems Manager Session Manager

For best security, use narrow `/32` SSH CIDRs, keep MySQL private, avoid opening application ports directly to the internet, and prefer SSM Session Manager over direct SSH when your network path supports it.

## Cost Notes

The lowest-cost configuration keeps NAT gateways disabled, avoids managed load balancers and RDS, disables detailed monitoring, and uses a small EC2 instance type. Enabling private-only instances with internet access through NAT gateways, VPC endpoints for SSM, load balancers, or managed database services will improve architecture separation but increase cost.
