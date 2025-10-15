#==========================================================================#
# Subnet                                                                   #
#==========================================================================#
resource "aws_subnet" "main" {
  for_each = var.subnets

  vpc_id            = var.vpc_id
  availability_zone = each.value.availability_zone

  # IPv4: ipv4_netnumが指定されている場合のみ
  cidr_block = (
    each.value.ipv4_netnum != null && var.vpc_cidr_block != null
    ? cidrsubnet(var.vpc_cidr_block, 8, each.value.ipv4_netnum)
    : null
  )

  # IPv6: vpc_ipv6_cidr_blockとipv6_netnumが両方指定されている場合のみ有効
  ipv6_cidr_block = (
    var.vpc_ipv6_cidr_block != null && each.value.ipv6_netnum != null
    ? cidrsubnet(var.vpc_ipv6_cidr_block, 8, each.value.ipv6_netnum)
    : null
  )

  # IPv6-onlyサブネット（IPv4なし、IPv6あり）
  ipv6_native                                    = each.value.ipv4_netnum == null && each.value.ipv6_netnum != null
  assign_ipv6_address_on_creation                = each.value.assign_ipv6_on_creation
  enable_resource_name_dns_aaaa_record_on_launch = each.value.ipv4_netnum == null && each.value.ipv6_netnum != null

  tags = {
    Name : "${var.service_prefix}-${each.key}"
  }
}

#==========================================================================#
# Route Table                                                                   #
#==========================================================================#
resource "aws_route_table" "main" {
  for_each = var.route_tables

  vpc_id = var.vpc_id

  # IPv4ルート
  dynamic "route" {
    for_each = local.enhanced_route_tables[each.key].ipv4_routes
    content {
      cidr_block = route.value.destination_cidr_block
      gateway_id = route.value.gateway_id
    }
  }

  # IPv6ルート
  dynamic "route" {
    for_each = local.enhanced_route_tables[each.key].ipv6_routes
    content {
      ipv6_cidr_block        = lookup(route.value, "destination_ipv6_cidr_block", null)
      gateway_id             = lookup(route.value, "gateway_id", null)
      egress_only_gateway_id = lookup(route.value, "egress_only_gateway_id", null)
    }
  }

  tags = {
    Name = "${var.service_prefix}-${each.key}-rtb"
  }
}

resource "aws_route_table_association" "main" {
  for_each = local.subnets_with_route_table

  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.main[each.value.route_table_name].id
}
