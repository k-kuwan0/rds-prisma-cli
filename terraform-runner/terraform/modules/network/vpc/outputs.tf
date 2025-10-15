output "vpc_id" {
  description = "作成されたVPCのID"
  value       = aws_vpc.main.id
}

output "cidr_block" {
  description = "VPCのIPv4 CIDRブロック"
  value       = aws_vpc.main.cidr_block
}

output "ipv6_cidr_block" {
  description = "VPCのIPv6 CIDRブロック（IPv6が有効な場合のみ）"
  value       = var.enable_ipv6 ? aws_vpc.main.ipv6_cidr_block : null
}

output "internet_gateway_id" {
  description = "Internet GatewayのID（作成された場合のみ）"
  value       = length(aws_internet_gateway.main) > 0 ? aws_internet_gateway.main[0].id : null
}

output "egress_only_internet_gateway_id" {
  description = "Egress Only Internet GatewayのID（IPv6が有効な場合のみ）"
  value       = length(aws_egress_only_internet_gateway.main) > 0 ? aws_egress_only_internet_gateway.main[0].id : null
}
