variable "service_name" {
  type        = string
  description = "サービス名"
}

variable "environment" {
  type        = string
  description = "環境名（dev / qa / stg / prod等）"
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2インスタンスタイプ"
  default     = "t3.micro"
}

variable "rds_instance_class" {
  type        = string
  description = "RDSインスタンスクラス"
  default     = "db.t4g.micro"
}

variable "rds_engine" {
  type        = string
  description = "RDSデータベースエンジン"
  default     = "mariadb"
}

variable "rds_engine_version" {
  type        = string
  description = "RDSエンジンバージョン"
  default     = "10.11"
}

variable "rds_port" {
  type        = number
  description = "RDSデータベースポート番号"
  default     = 3306
}

variable "enable_ipv6" {
  type        = bool
  description = "IPv6を有効にするかどうか"
  default     = true
}

