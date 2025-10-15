# Security Group outputs
output "security_group_ids" {
  description = "セキュリティグループIDのマップ（設定キー名がキー）"
  value = {
    for key, sg in aws_security_group.main : key => sg.id
  }
}
