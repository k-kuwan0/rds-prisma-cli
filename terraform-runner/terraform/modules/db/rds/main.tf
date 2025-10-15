#==========================================================================#
# RDS Subnet Group                                                         #
#==========================================================================#
resource "aws_db_subnet_group" "main" {
  name       = "${var.service_prefix}-rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.service_prefix}-rds-subnet-group"
  }
}

#==========================================================================#
# RDS                                                                      #
#==========================================================================#
resource "aws_db_instance" "main" {
  # 基本設定
  identifier     = "${var.service_prefix}-rds"
  engine         = var.instance_config.engine
  engine_version = var.instance_config.engine_version
  instance_class = var.instance_config.instance_class

  # データベース設定
  db_name                     = var.db_config.db_name
  username                    = var.db_config.username
  manage_master_user_password = true # 基本的にSecrets Managerを使う

  # ストレージ設定
  allocated_storage     = var.storage_config.allocated_storage
  storage_type          = var.storage_config.storage_type
  max_allocated_storage = var.storage_config.max_allocated_storage # 自動スケーリング

  # ネットワーク設定
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.network_config.vpc_security_group_ids
  publicly_accessible    = var.network_config.publicly_accessible
  port                   = var.network_config.port
  network_type           = var.network_config.network_type

  # 可用性設定
  multi_az = var.multi_az

  # バックアップ設定
  backup_retention_period = var.backup_retention_period

  # モニタリング設定
  monitoring_interval = var.monitoring_interval

  # セキュリティ設定
  deletion_protection = var.deletion_protection # 削除保護

  # ログ設定
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  # その他設定
  skip_final_snapshot = true # 削除時のスナップショット作成をスキップ
  apply_immediately   = true

  tags = {
    Name = "${var.service_prefix}-rds"
  }
}

#==========================================================================#
# Secrets Manager Rotation                                                #
#==========================================================================#
resource "aws_secretsmanager_secret_rotation" "main" {
  secret_id = aws_db_instance.main.master_user_secret[0].secret_arn

  rotation_rules {
    automatically_after_days = var.rotation_cycle
  }

  rotate_immediately = true
}

