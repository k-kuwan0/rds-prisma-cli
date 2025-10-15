terraform {
  backend "s3" {
    # お好みのバケット名を設定する
    bucket  = "terraform-state-kuwan0"
    key     = "rds-prisma/dev/terraform.state"
    region  = "ap-northeast-1"
    profile = "rds-prisma"
  }
}
