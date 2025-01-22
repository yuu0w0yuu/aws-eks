module "acm" {
  source = "terraform-aws-modules/acm/aws"

  domain_name = aws_route53_record.test_lb.fqdn
  zone_id     = data.aws_route53_zone.zone.zone_id

  validation_method = "DNS"

  subject_alternative_names = [format("*.%s", aws_route53_record.test_lb.fqdn)]

  tags = {
    Name = "${local.prefix}-test-lb-certificate"
  }
}