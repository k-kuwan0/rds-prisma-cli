#==========================================================================#
# IAM Policy Document                                                      #
#==========================================================================#
data "aws_iam_policy_document" "assume_role" {
  for_each = var.role_config

  version = local.policy_version

  statement {
    sid     = each.value.assume_role_policy_document.sid
    effect  = each.value.assume_role_policy_document.effect
    actions = each.value.assume_role_policy_document.actions
    principals {
      type        = each.value.assume_role_policy_document.principals.type
      identifiers = each.value.assume_role_policy_document.principals.identifiers
    }
  }
}

data "aws_iam_policy_document" "inline" {
  for_each = var.role_config

  version = local.policy_version

  dynamic "statement" {
    for_each = each.value.inline_policy_document
    content {
      sid       = statement.value.key
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

#==========================================================================#
# IAM Role                                                                 #
#==========================================================================#
resource "aws_iam_role" "main" {
  for_each = var.role_config

  name               = "${var.service_prefix}-${each.key}-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role[each.key].json

  # カスタマー管理ポリシーで管理したいシーンがないため、インラインで作成する
  dynamic "inline_policy" {
    # inline_policy_documentが空の場合はインラインポリシーを割り当てない
    for_each = length(each.value.inline_policy_document) > 0 ? [1] : []
    content {
      name   = "${var.service_prefix}-${each.key}-iam-role-inline_policy"
      policy = data.aws_iam_policy_document.inline[each.key].json
    }
  }
}

resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = {
    # 2層のlistになるため、1次元の配列に変換 -> for_eachで処理可能なmapとして展開する
    for managed_policies in flatten([
      for key, config in var.role_config : [
        for policy_arn in config.managed_policy_arns : {
          # この部分がeachのvalueとなる
          key        = "${key}-${replace(policy_arn, "/[^a-zA-Z0-9]/", "-")}"
          role_key   = key
          policy_arn = policy_arn
        }
      ]
    ]) : managed_policies.key => managed_policies
  }

  role       = aws_iam_role.main[each.value.role_key].name
  policy_arn = each.value.policy_arn
}

#==========================================================================#
# Instance Profile                                                         #
#==========================================================================#
resource "aws_iam_instance_profile" "main" {
  for_each = {
    for key, config in var.role_config : key => config
    if config.use_profile == true
  }

  name = "${var.service_prefix}-${each.key}-iam-role-instance-profile"
  role = aws_iam_role.main[each.key].name
}
