variable "service_prefix" {
  type        = string
  description = "サービスプレフィックス"
}

variable "role_config" {
  type = map(object({
    assume_role_policy_document = optional(
      object({
        sid     = string
        effect  = string
        actions = list(string)
        principals = object({
          type        = string
          identifiers = list(string)
        })
      })
    )
    inline_policy_document = optional(
      map(
        object({
          effect    = string
          actions   = list(string)
          resources = list(string)
        })
      ),
      {}
    )
    managed_policy_arns = optional(list(string), [])
    use_profile         = optional(bool, false)
  }))
  description = <<-EOT
    IAMロール設定のマップ
    - assume_role_policy_document: AssumeRoleポリシードキュメント（信頼ポリシー）
      - sid: ステートメントID
      - effect: 効果（Allow, Deny）
      - actions: 許可するアクション（例: ["sts:AssumeRole"]）
      - principals: プリンシパル（信頼するエンティティ）
        - type: プリンシパルタイプ（Service, AWS, Federated等）
        - identifiers: プリンシパルの識別子リスト（例: ["ec2.amazonaws.com"]）
    - inline_policy_document: インラインポリシードキュメントのマップ
      - effect: 効果（Allow, Deny）
      - actions: 許可するアクションのリスト
      - resources: 対象リソースのARNリスト
    - managed_policy_arns: アタッチするAWSマネージドポリシーARNのリスト
    - use_profile: EC2インスタンスプロファイルを作成するかどうか
  EOT
}
