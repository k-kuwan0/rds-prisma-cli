locals {
  # サービスプレフィックス
  service_prefix = "${var.service_name}-${var.environment}"

  # リージョン設定
  aws_region = "ap-northeast-1"

  # アベイラビリティゾーン
  availability_zones = {
    primary   = "ap-northeast-1a"
    secondary = "ap-northeast-1c"
  }

  # ネットワーク設定
  vpc_cidr = "10.0.0.0/16"

  # 一般的なポート番号
  ports = {
    https = 443
  }

  # VPCエンドポイントサービス名のプレフィックス
  vpc_endpoint_service_prefix = "com.amazonaws.${local.aws_region}"
}
