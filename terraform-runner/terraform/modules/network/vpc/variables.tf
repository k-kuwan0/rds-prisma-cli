variable "service_prefix" {
  type        = string
  description = "サービスプレフィックス"
}

variable "cidr_block" {
  type        = string
  description = "VPCのIPv4 CIDRブロック（例: 10.0.0.0/16）"
}

variable "enable_dns_support" {
  type        = bool
  description = "VPC内でDNS解決を有効にするかどうか"
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "VPC内のインスタンスにDNSホスト名を割り当てるかどうか"
  default     = true
}

variable "enable_internet_gateway" {
  type        = bool
  description = "インターネットゲートウェイを作成するかどうか"
  default     = false
}

variable "enable_ipv6" {
  type        = bool
  description = "IPv6を有効にするかどうか（IPv6 CIDRブロックとEgress Only IGWが作成される）"
  default     = false
}
