output "endpoint_ids" {
  description = "VPCエンドポイントIDのマップ（設定キー名がキー）"
  value = {
    for key, endpoint in aws_vpc_endpoint.main : key => endpoint.id
  }
}

output "endpoint_dns_entries" {
  description = "VPCエンドポイントのDNSエントリのマップ（設定キー名がキー）"
  value = {
    for key, endpoint in aws_vpc_endpoint.main : key => endpoint.dns_entry
  }
}
