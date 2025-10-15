variable "service_prefix" {
  type        = string
  description = "サービスプレフィックス"
}

variable "vpc_id" {
  type        = string
  description = "VPCエンドポイントを作成するVPCのID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "InterfaceタイプのVPCエンドポイントを配置するサブネットIDのリスト"
}

variable "security_group_ids" {
  type        = list(string)
  description = "InterfaceタイプのVPCエンドポイントにアタッチするセキュリティグループIDのリスト"
  default     = []
}

variable "route_table_ids" {
  type        = list(string)
  description = "GatewayタイプのVPCエンドポイント（S3、DynamoDB等）に関連付けるルートテーブルIDのリスト"
  default     = []
}

variable "endpoints" {
  type = map(object({
    service_name    = string
    service_type    = optional(string, "Interface")
    ip_address_type = optional(string, "ipv4")
  }))
  description = <<-EOT
    作成するVPCエンドポイントのマップ
    - service_name: AWSサービスエンドポイント名（例: com.amazonaws.ap-northeast-1.s3）
    - service_type: エンドポイントタイプ（Interface, Gateway, GatewayLoadBalancer）
    - ip_address_type: IPアドレスタイプ（ipv4, ipv6, dualstack）※Interfaceタイプのみ有効
  EOT
}
