# サービス名
service_name = "prisma-rds-manager"
# 環境名
environment = "dev"

# EC2設定（開発環境用の小さいインスタンス）
ec2_instance_type = "t3.micro"

# RDS設定（開発環境用の小さいインスタンス）
rds_instance_class = "db.t4g.micro"
rds_engine         = "mariadb"
rds_engine_version = "10.11"
rds_port           = 3306

# IPv6設定
enable_ipv6 = true
