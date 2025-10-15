# Subnet outputs
output "subnet_ids" {
  description = "サブネットIDのマップ（設定キー名がキー）"
  value = {
    for key, subnet in aws_subnet.main : key => subnet.id
  }
}

output "subnet_ipv6_cidr_blocks" {
  description = "サブネットのIPv6 CIDRブロックのマップ（設定キー名がキー）"
  value = {
    for key, subnet in aws_subnet.main : key => subnet.ipv6_cidr_block
  }
}

output "route_table_ids" {
  description = "ルートテーブルIDのマップ（設定キー名がキー）"
  value = {
    for key, rt in aws_route_table.main : key => rt.id
  }
}
