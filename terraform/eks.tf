module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = "${local.prefix}-cluster"
  cluster_version = local.cluster_version

  vpc_id     = aws_vpc.main_vpc.id
  subnet_ids = [for value in aws_subnet.private_subnet : value.id]

}