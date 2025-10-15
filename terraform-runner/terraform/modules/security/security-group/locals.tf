locals {
  ingress_rules = merge([
    for sg_key, sg_value in var.security_groups : {
      for rule_key, rule_value in sg_value.ingress_rule :
      "${sg_key}-${rule_key}" => merge(rule_value, {
        security_group_key = sg_key
        rule_key           = rule_key
      })
    }
  ]...)
  egress_rules = merge([
    for sg_key, sg_value in var.security_groups : {
      for rule_key, rule_value in sg_value.egress_rule :
      "${sg_key}-${rule_key}" => merge(rule_value, {
        security_group_key = sg_key
        rule_key           = rule_key
      })
    }
  ]...)
}
