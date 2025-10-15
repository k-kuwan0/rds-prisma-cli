variable "service_prefix" {
  type        = string
  description = "サービスプレフィックス"
}

variable "vpc_id" {
  type        = string
  description = "サブネットを作成するVPCのID"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPCのIPv4 CIDRブロック（IPv4サブネット作成に使用）"
  default     = null
}

variable "internet_gateway_id" {
  type        = string
  description = "インターネットゲートウェイのID（パブリックサブネットのルート設定に使用）"
  default     = null
}

variable "vpc_ipv6_cidr_block" {
  type        = string
  description = "VPCのIPv6 CIDRブロック（IPv6サブネット作成に使用）"
  default     = null
}

variable "egress_only_internet_gateway_id" {
  type        = string
  description = "Egress OnlyインターネットゲートウェイのID（プライベートサブネットのIPv6アウトバウンドルート設定に使用）"
  default     = null
}

variable "subnets" {
  type = map(object({
    ipv4_netnum             = optional(number)
    availability_zone       = string
    route_table_name        = optional(string)
    ipv6_netnum             = optional(number)
    assign_ipv6_on_creation = optional(bool, false)
  }))
  description = <<-EOT
    サブネット設定のマップ
    - ipv4_netnum: IPv4サブネットのネットワーク番号（cidrsubnetの第3引数、nullでIPv4なし）
    - availability_zone: サブネットを配置するアベイラビリティゾーン
    - route_table_name: 関連付けるルートテーブルの名前（route_tablesマップのキー）
    - ipv6_netnum: IPv6サブネットのネットワーク番号（cidrsubnetの第3引数、nullでIPv6なし）
    - assign_ipv6_on_creation: 起動時にIPv6アドレスを自動割り当てするかどうか
  EOT
}

variable "route_tables" {
  type = map(object({
    is_public = optional(bool, false)
    routes = map(object({
      destination_cidr_block = string
      gateway_id             = optional(string)
    }))
  }))
  description = <<-EOT
    ルートテーブル設定のマップ
    - is_public: パブリックサブネット用かどうか（trueの場合、IGW経由のデフォルトルートが自動追加される）
    - routes: カスタムルートのマップ
      - destination_cidr_block: 宛先CIDRブロック
      - gateway_id: ゲートウェイID（IGW、VGW等）
  EOT
}
