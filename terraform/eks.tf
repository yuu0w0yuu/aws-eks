### EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = "${local.prefix}-cluster"
  cluster_version = local.cluster_version

  vpc_id                               = aws_vpc.main_vpc.id
  subnet_ids                           = [for value in aws_subnet.private_subnet : value.id]
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = local.eks_public_access_cidrs

  cloudwatch_log_group_class = "INFREQUENT_ACCESS"

  ### Access Entry
  access_entries = {
    admin = {
      kubernetes_groups = []
      principal_arn     = join(", ", data.aws_iam_roles.sso_administrator.arns)
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  ## Managed Node Group
  eks_managed_node_groups = {
    system = {
      name                          = "system"
      use_name_prefix               = false
      ami_id                        = "ami-06201496943722c09"
      subnet_ids                    = [for value in aws_subnet.private_subnet : value.id]
      additional_security_group_ids = [module.node_sg.security_group_id]
      min_size                      = 1
      max_size                      = 1
      desired_size                  = 1
      instance_types                = ["m6i.large", "m6i.xlarge", "m6i.2xlarge"]
      capacity_type                 = "SPOT"
      enable_bootstrap_user_data    = true
      labels = {
        "workload/system" = "true"
      }
    },
    app = {
      name                          = "app"
      use_name_prefix               = false
      ami_type                      = "AL2_x86_64"
      ami_id                        = "ami-06201496943722c09"
      subnet_ids                    = [for value in aws_subnet.private_subnet : value.id]
      additional_security_group_ids = [module.node_sg.security_group_id]
      min_size                      = 1
      max_size                      = 1
      desired_size                  = 1
      instance_types                = ["m6i.large", "m6i.xlarge", "m6i.2xlarge"]
      capacity_type                 = "SPOT"
      enable_bootstrap_user_data    = true
      labels = {
        "workload/app" = "true"
      }
    }
  }

  tags = local.required_tags

}

#EBSマウント用EBS CSIドライバ
module "iam_assumable_role_ebs_csi_driver" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role                   = true
  role_name                     = "${local.prefix}-ebs-csi-driver"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.28.0-eksbuild.1"
  service_account_role_arn = module.iam_assumable_role_ebs_csi_driver.iam_role_arn
}

#自動停止設定（ノードグループのデフォルトのAutoScallingGroup設定を修正）
resource "aws_autoscaling_schedule" "stop_eks_node-group" {
  scheduled_action_name  = "stop-${local.prefix}-eks-cluster"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "0 0 * * MON-FRI"
  time_zone              = "Asia/Tokyo"
  autoscaling_group_name = module.eks.eks_managed_node_groups_autoscaling_group_names[0]
}

resource "aws_autoscaling_schedule" "start_eks_node-group" {
  scheduled_action_name  = "start-${local.prefix}-eks-cluster"
  min_size               = 1
  max_size               = 1
  desired_capacity       = 1
  recurrence             = "0 9 * * MON-FRI"
  time_zone              = "Asia/Tokyo"
  autoscaling_group_name = module.eks.eks_managed_node_groups_autoscaling_group_names[0]
}
