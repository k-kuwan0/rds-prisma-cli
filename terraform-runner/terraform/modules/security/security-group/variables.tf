variable "service_prefix" {
  type        = string
  description = "サービスプレフィックス"
}

variable "vpc_id" {
  type        = string
  description = "セキュリティグループを作成するVPCのID"
}

variable "security_groups" {
  type = map(object({
    ingress_rule = map(object({
      cidr_ipv4                 = optional(string)
      cidr_ipv6                 = optional(string)
      from_port                 = optional(number)
      ip_protocol               = string
      to_port                   = optional(number)
      referenced_security_group = optional(string)
    }))
    egress_rule = map(object({
      cidr_ipv4                 = optional(string)
      cidr_ipv6                 = optional(string)
      from_port                 = optional(number)
      ip_protocol               = string
      to_port                   = optional(number)
      referenced_security_group = optional(string)
    }))
  }))
  description = <<-EOT
    セキュリティグループ設定のマップ
    - ingress_rule: インバウンドルールのマップ
      - cidr_ipv4: 送信元IPv4 CIDRブロック
      - cidr_ipv6: 送信元IPv6 CIDRブロック
      - from_port: 開始ポート番号（プロトコルによってはオプション）
      - ip_protocol: IPプロトコル（tcp, udp, icmp, icmpv6, -1（すべて）等）
      - to_port: 終了ポート番号（プロトコルによってはオプション）
      - referenced_security_group: 参照先セキュリティグループ名（同じsecurity_groupsマップ内のキー）
    - egress_rule: アウトバウンドルールのマップ
      - cidr_ipv4: 宛先IPv4 CIDRブロック
      - cidr_ipv6: 宛先IPv6 CIDRブロック
      - from_port: 開始ポート番号（プロトコルによってはオプション）
      - ip_protocol: IPプロトコル（tcp, udp, icmp, icmpv6, -1（すべて）等）
      - to_port: 終了ポート番号（プロトコルによってはオプション）
      - referenced_security_group: 参照先セキュリティグループ名（同じsecurity_groupsマップ内のキー）
  EOT
}
