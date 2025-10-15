#==========================================================================#
# Security Group                                                           #
#==========================================================================#
resource "aws_security_group" "main" {
  for_each = var.security_groups

  vpc_id = var.vpc_id
  name   = "${var.service_prefix}-${each.key}-sg"

  tags = {
    Name = "${var.service_prefix}-${each.key}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "main" {
  for_each = local.ingress_rules

  security_group_id            = aws_security_group.main[each.value.security_group_key].id
  cidr_ipv4                    = lookup(each.value, "cidr_ipv4", null)
  cidr_ipv6                    = lookup(each.value, "cidr_ipv6", null)
  from_port                    = each.value.from_port
  ip_protocol                  = each.value.ip_protocol
  to_port                      = each.value.to_port
  referenced_security_group_id = each.value.referenced_security_group != null ? aws_security_group.main[each.value.referenced_security_group].id : null

  tags = {
    Name = each.value.rule_key
  }
}

resource "aws_vpc_security_group_egress_rule" "name" {
  for_each = local.egress_rules

  security_group_id            = aws_security_group.main[each.value.security_group_key].id
  cidr_ipv4                    = lookup(each.value, "cidr_ipv4", null)
  cidr_ipv6                    = lookup(each.value, "cidr_ipv6", null)
  from_port                    = lookup(each.value, "from_port", null)
  ip_protocol                  = each.value.ip_protocol
  to_port                      = lookup(each.value, "to_port", null)
  referenced_security_group_id = lookup(each.value, "referenced_security_group", null) != null ? aws_security_group.main[each.value.referenced_security_group].id : null

  tags = {
    Name = each.value.rule_key
  }
}
