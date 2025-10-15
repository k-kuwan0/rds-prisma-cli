#==========================================================================#
# VPC Endpoint                                                             #
#==========================================================================#
resource "aws_vpc_endpoint" "main" {
  for_each = var.endpoints

  vpc_id              = var.vpc_id
  service_name        = each.value.service_name
  vpc_endpoint_type   = each.value.service_type
  private_dns_enabled = each.value.service_type == "Interface" ? true : false
  ip_address_type     = each.value.service_type == "Interface" ? each.value.ip_address_type : null

  # Interfaceエンドポイントの場合のみサブネットとセキュリティグループを設定
  subnet_ids         = each.value.service_type == "Interface" ? var.subnet_ids : null
  security_group_ids = each.value.service_type == "Interface" && length(var.security_group_ids) > 0 ? var.security_group_ids : null

  # Gatewayエンドポイントの場合のみルートテーブルを設定
  route_table_ids = each.value.service_type == "Gateway" ? var.route_table_ids : null

  tags = {
    Name = "${var.service_prefix}-${each.key}-endpoint"
  }
}