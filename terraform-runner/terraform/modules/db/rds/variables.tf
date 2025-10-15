variable "service_prefix" {
  type        = string
  description = "サービスプレフィックス"
}

variable "subnet_ids" {
  type        = list(string)
  description = "DBサブネットグループに含めるサブネットIDのリスト"
}

variable "instance_config" {
  type = object({
    engine         = string
    engine_version = string
    instance_class = optional(string, "db.t3.micro")
  })
  description = <<-EOT
    インスタンス設定オブジェクト
    - engine: データベースエンジン（mysql, postgres, mariadb等）
    - engine_version: エンジンバージョン（例: 8.0, 13.7等）
    - instance_class: インスタンスタイプ（例: db.t3.micro, db.t3.small等）
  EOT
}

variable "db_config" {
  type = object({
    db_name  = optional(string, "default")
    username = string
  })
  description = <<-EOT
    DB設定オブジェクト
    - db_name: 初期データベース名（作成するデータベース名）
    - username: マスターユーザー名（管理者ユーザー名）
  EOT
}

variable "storage_config" {
  type = object({
    allocated_storage     = number
    storage_type          = string
    max_allocated_storage = optional(number, 0)
  })
  description = <<-EOT
    ストレージ設定オブジェクト
    - allocated_storage: 初期ストレージサイズ（GB単位）
    - storage_type: ストレージタイプ（gp2, gp3, io1等）
    - max_allocated_storage: 自動スケーリング最大サイズ（0で無効、GB単位）
  EOT
}

variable "network_config" {
  type = object({
    vpc_security_group_ids = list(string)
    publicly_accessible    = optional(bool, false)
    port                   = number
    network_type           = optional(string, "IPV4")
  })
  description = <<-EOT
    ネットワーク設定オブジェクト
    - vpc_security_group_ids: アタッチするセキュリティグループIDのリスト
    - publicly_accessible: パブリックアクセス可否（true: 有効, false: 無効）
    - port: データベース接続ポート番号（MySQL: 3306, PostgreSQL: 5432等）
    - network_type: ネットワークタイプ（IPV4, DUAL）
  EOT
}

variable "rotation_cycle" {
  type        = number
  description = "パスワードローテーションサイクル（日数）"
}

variable "multi_az" {
  type        = bool
  description = "マルチAZを有効化するかどうか"
  default     = false # シングルAZ
}

variable "backup_retention_period" {
  type        = number
  description = "自動バックアップの保持期間（日数、0で無効）"
  default     = 0 # 自動バックアップ無効
}

variable "monitoring_interval" {
  type        = number
  description = "拡張モニタリングの間隔（秒、0で無効）"
  default     = 0 # 拡張モニタリング無効
}

variable "deletion_protection" {
  type        = bool
  description = "削除保護を有効化するかどうか"
  default     = false # 削除保護無効
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "CloudWatch Logsにエクスポートするログタイプのリスト（例: [\"error\", \"general\", \"slowquery\"]）"
  default     = [] # ログエクスポートなし
}

variable "skip_final_snapshot" {
  type        = bool
  description = "削除時の最終スナップショット作成をスキップするかどうか"
  default     = false # 削除時のスナップショット作成をスキップ
}

variable "apply_immediately" {
  type        = bool
  description = "変更を次のメンテナンスウィンドウではなく即座に適用するかどうか"
  default     = false # DBの変更を即座に適用する
}
