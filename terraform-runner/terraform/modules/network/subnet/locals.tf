locals {
  # ルートテーブルにデフォルトルートを追加した拡張版
  enhanced_route_tables = {
    for rt_name, rt_config in var.route_tables : rt_name => {
      # IPv4ルート：パブリックかつIGWがある場合、デフォルトルートを追加
      ipv4_routes = rt_config.is_public && var.internet_gateway_id != null ? merge(
        rt_config.routes,
        {
          "internet_gateway" = {
            destination_cidr_block = "0.0.0.0/0"
            gateway_id             = var.internet_gateway_id
          }
        }
      ) : rt_config.routes

      # IPv6ルート：条件に応じて追加
      ipv6_routes = var.vpc_ipv6_cidr_block != null ? (
        rt_config.is_public && var.internet_gateway_id != null ? {
          # パブリックサブネット：IGW経由でインターネットへ
          "internet_gateway_ipv6" = {
            destination_ipv6_cidr_block = "::/0"
            gateway_id                  = var.internet_gateway_id
          }
          } : var.egress_only_internet_gateway_id != null ? {
          # プライベートサブネット：Egress-Only IGW経由でアウトバウンドのみ
          "egress_only_igw_ipv6" = {
            destination_ipv6_cidr_block = "::/0"
            egress_only_gateway_id      = var.egress_only_internet_gateway_id
          }
        } : {}
      ) : {}
    }
  }

  # ルートテーブルに関連付けるサブネット（route_table_nameが指定されているもののみ）
  subnets_with_route_table = {
    for subnet_name, subnet_config in var.subnets : subnet_name => subnet_config
    if subnet_config.route_table_name != null
  }
}
