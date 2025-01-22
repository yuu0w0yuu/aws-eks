module "iam_role_sa_eks_lb_controller" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  create_role = true
  role_name   = "${local.prefix}-aws-load-balancer-controller-role"
  tags        = local.required_tags

  attach_load_balancer_controller_policy = true
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}