module "alb_sg" {
  source = "./modules/security_group"

  prefix = local.prefix
  vpc_id = aws_vpc.main_vpc.id
  suffix = "alb"

  sg_rule_ingress = [
    {
      description     = "Allow HTTP inbound"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = null
      cidr_blocks     = ["0.0.0.0/0"]
    },
    {
      description     = "Allow HTTPS inbound"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = null
      cidr_blocks     = ["0.0.0.0/0"]
    }
  ]
}

module "node_sg" {
  source = "./modules/security_group"

  prefix = local.prefix
  vpc_id = aws_vpc.main_vpc.id
  suffix = "node"

  sg_rule_ingress = [
    {
      description     = "Allow inbound from ELB"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      security_groups = [module.alb_sg.security_group_id]
      cidr_blocks     = null
    }
  ]
}