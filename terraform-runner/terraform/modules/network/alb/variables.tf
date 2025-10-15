variable "service_prefix" {
  type        = string
  description = "サービスプレフィックス"
}

variable "vpc_id" {
  type        = string
  description = "ALBを配置するVPCのID"
}

variable "security_group_ids" {
  type        = list(string)
  description = "ALBにアタッチするセキュリティグループIDのリスト"
}

variable "subnet_ids" {
  type        = list(string)
  description = "ALBを配置するサブネットIDのリスト（最低2つのAZが必要）"
}

variable "ip_address_type" {
  type        = string
  description = "IPアドレスタイプ（ipv4, dualstack, dualstack-without-public-ipv4）"
}

variable "internal" {
  type        = bool
  description = "内部向けALB（インターネット向けでない）にするかどうか"
  default     = false
}

variable "target_groups" {
  type = map(
    object({
      port             = number
      protocol         = string
      protocol_version = string
      target_type      = string
      health_check = map(
        object({
          enabled             = bool
          healthy_threshold   = number
          unhealthy_threshold = number
          timeout             = number
          interval            = number
          path                = string
          matcher             = string
          port                = string
          protocol            = string
        })
      )
      targets = list(
        object({
          id   = string
          port = number
        })
      )
      listeners = map(
        object({
          port     = number
          protocol = string
          type     = string
        })
      )
    })
  )
  description = <<-EOT
    ターゲットグループの設定マップ
    - port: ターゲットが受信するポート番号
    - protocol: ターゲットへのトラフィックに使用するプロトコル（HTTP, HTTPS等）
    - protocol_version: プロトコルバージョン（HTTP1, HTTP2, GRPC等）
    - target_type: ターゲットタイプ（instance, ip, lambda等）
    - health_check: ヘルスチェック設定
      - enabled: ヘルスチェックを有効化するかどうか
      - healthy_threshold: 正常と判断するまでの連続成功回数
      - unhealthy_threshold: 異常と判断するまでの連続失敗回数
      - timeout: ヘルスチェックのタイムアウト時間（秒）
      - interval: ヘルスチェックの間隔（秒）
      - path: ヘルスチェックのパス
      - matcher: 成功を示すHTTPステータスコード
      - port: ヘルスチェックのポート
      - protocol: ヘルスチェックのプロトコル
    - targets: ターゲットのリスト
      - id: ターゲットID（インスタンスIDまたはIPアドレス）
      - port: ターゲットのポート番号
    - listeners: リスナーの設定マップ
      - port: リスナーが受信するポート番号
      - protocol: リスナーのプロトコル（HTTP, HTTPS等）
      - type: アクションタイプ（forward, redirect等）
  EOT
}
