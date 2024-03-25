locals {
  # 共通設定
  service = "shirayama"
  env     = "eks"
  prefix  = "${local.service}-${local.env}"

  required_tags = {
    creator   = "yutaro.shirayama"
    terraform = "true"
  }

  # VPC設定
  vpc_cidr = "10.0.0.0/16"

  public_subnets = [
    { cidr = "10.0.1.0/24", az = "ap-northeast-1a" },
    { cidr = "10.0.2.0/24", az = "ap-northeast-1c" }
  ]

  private_subnets = [
    { cidr = "10.0.11.0/24", az = "ap-northeast-1a" },
    { cidr = "10.0.12.0/24", az = "ap-northeast-1c" }
  ]

  # EKS
  cluster_version = "1.29"
  eks_public_access_cidrs = [
    "0.0.0.0/0"
  ]

}