#==========================================================================#
# IAM                                                                      #
#==========================================================================#
module "iam" {
  source = "../../modules/security/iam"

  service_prefix = local.service_prefix
  role_config = {
    ec2 = {
      assume_role_policy_document = {
        sid     = "AllowEC2ServiceAssumeRole"
        effect  = "Allow"
        actions = ["sts:AssumeRole"]
        principals = {
          type        = "Service"
          identifiers = ["ec2.amazonaws.com"]
        }
      }
      managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
      use_profile         = true
    }
  }
}

#==========================================================================#
# VPC                                                                      #
#==========================================================================#
module "vpc" {
  source = "../../modules/network/vpc"

  service_prefix          = local.service_prefix
  cidr_block              = local.vpc_cidr
  enable_dns_support      = true
  enable_dns_hostnames    = true
  enable_internet_gateway = true
  enable_ipv6             = var.enable_ipv6
}

#==========================================================================#
# Subnet                                                                   #
#==========================================================================#
module "subnets" {
  source = "../../modules/network/subnet"

  service_prefix                  = local.service_prefix
  vpc_id                          = module.vpc.vpc_id
  vpc_cidr_block                  = module.vpc.cidr_block
  vpc_ipv6_cidr_block             = module.vpc.ipv6_cidr_block
  internet_gateway_id             = module.vpc.internet_gateway_id
  egress_only_internet_gateway_id = module.vpc.egress_only_internet_gateway_id
  subnets = {
    private1 = {
      ipv4_netnum             = 10
      ipv6_netnum             = 10
      availability_zone       = local.availability_zones.primary
      assign_ipv6_on_creation = true
      route_table_name        = "private"
    }
    private2 = {
      ipv4_netnum             = 11
      ipv6_netnum             = 11
      availability_zone       = local.availability_zones.secondary
      assign_ipv6_on_creation = true
      route_table_name        = "private"
    }
  }
  route_tables = {
    private = {
      is_public = false
      routes    = {}
    }
  }
}

#==========================================================================#
# VPC Endpoint                                                             #
#==========================================================================#
module "vpc_endpoints" {
  source = "../../modules/network/vpc-endpoint"

  service_prefix     = local.service_prefix
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = [module.subnets.subnet_ids["private1"], module.subnets.subnet_ids["private2"]]
  route_table_ids    = [module.subnets.route_table_ids["private"]]
  security_group_ids = [module.security_groups.security_group_ids["vpc_endpoint"]]
  endpoints = {
    ssm = {
      service_name    = "${local.vpc_endpoint_service_prefix}.ssm"
      service_type    = "Interface"
      ip_address_type = "ipv4"
    }
    ssmmessages = {
      service_name    = "${local.vpc_endpoint_service_prefix}.ssmmessages"
      service_type    = "Interface"
      ip_address_type = "ipv4"
    }
    ec2messages = {
      service_name    = "${local.vpc_endpoint_service_prefix}.ec2messages"
      service_type    = "Interface"
      ip_address_type = "ipv4"
    }
    s3 = {
      service_name = "${local.vpc_endpoint_service_prefix}.s3"
      service_type = "Gateway"
    }
  }
}

#==========================================================================#
# Security Group                                                           #
#==========================================================================#
module "security_groups" {
  source = "../../modules/security/security-group"

  service_prefix = local.service_prefix
  vpc_id         = module.vpc.vpc_id
  security_groups = {
    ec2 = {
      ingress_rule = {}
      egress_rule = {
        outbound-https-ipv4 = {
          cidr_ipv4   = module.vpc.cidr_block
          from_port   = local.ports.https
          ip_protocol = "tcp"
          to_port     = local.ports.https
        }
        outbound-https-ipv6 = {
          cidr_ipv6   = "::/0"
          from_port   = local.ports.https
          ip_protocol = "tcp"
          to_port     = local.ports.https
        }
        outbound-mariadb-to-rds = {
          from_port                 = var.rds_port
          ip_protocol               = "tcp"
          to_port                   = var.rds_port
          referenced_security_group = "rds"
        }
      }
    }
    vpc_endpoint = {
      ingress_rule = {
        inbound-https-from-vpc = {
          cidr_ipv4   = module.vpc.cidr_block
          from_port   = local.ports.https
          ip_protocol = "tcp"
          to_port     = local.ports.https
        }
      }
      egress_rule = {
        outbound-to-vpc = {
          cidr_ipv4   = module.vpc.cidr_block
          ip_protocol = "-1"
        }
      }
    }
    rds = {
      ingress_rule = {
        inbound-from-ec2 = {
          from_port                 = var.rds_port
          ip_protocol               = "tcp"
          to_port                   = var.rds_port
          referenced_security_group = "ec2"
        }
      }
      egress_rule = {}
    }
  }
}

#==========================================================================#
# AMI                                                                      #
#==========================================================================#
data "aws_ami" "main" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#==========================================================================#
# EC2 Instance                                                             #
#==========================================================================#
resource "aws_instance" "main" {
  ami                         = data.aws_ami.main.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = module.subnets.subnet_ids["private1"]
  vpc_security_group_ids      = [module.security_groups.security_group_ids["ec2"]]
  associate_public_ip_address = false
  ipv6_address_count          = 1
  iam_instance_profile        = module.iam.instance_profile_names["ec2"]

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  tags = {
    Name = "${local.service_prefix}-ec2-bastion"
  }
}

#==========================================================================#
# RDS                                                                      #
#==========================================================================#
module "rds" {
  source = "../../modules/db/rds"

  service_prefix = local.service_prefix
  subnet_ids     = [module.subnets.subnet_ids["private1"], module.subnets.subnet_ids["private2"]]
  instance_config = {
    engine         = var.rds_engine
    engine_version = var.rds_engine_version
    instance_class = var.rds_instance_class
  }
  db_config = {
    db_name  = "main"
    username = "db_admin"
  }
  storage_config = {
    allocated_storage     = 20
    storage_type          = "gp3"
    max_allocated_storage = 0 # 開発環境: ストレージ自動スケーリング無効（コスト削減）
  }
  network_config = {
    vpc_security_group_ids = [module.security_groups.security_group_ids["rds"]]
    publicly_accessible    = false
    port                   = var.rds_port
    network_type           = "DUAL"
  }
  rotation_cycle                  = 30
  multi_az                        = false # 開発環境: シングルAZ構成（コスト削減）
  backup_retention_period         = 0     # 開発環境: 自動バックアップ無効（コスト削減）
  monitoring_interval             = 0     # 開発環境: 拡張モニタリング無効（コスト削減）
  deletion_protection             = false # 開発環境: 削除保護無効（柔軟な環境削除のため）
  enabled_cloudwatch_logs_exports = []    # 開発環境: ログエクスポート無効（コスト削減）
  skip_final_snapshot             = false # 削除時に最終スナップショット作成（データ保護）
  apply_immediately               = false # メンテナンスウィンドウで変更適用
}
