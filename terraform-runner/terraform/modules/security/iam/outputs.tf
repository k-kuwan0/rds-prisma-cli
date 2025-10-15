# Instance Profile outputs
output "instance_profile_names" {
  description = "IAMインスタンスプロファイル名のマップ（設定キー名がキー）"
  value = {
    for key, profile in aws_iam_instance_profile.main : key => profile.name
  }
}
