resource "aws_route53_record" "test_lb" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${local.prefix}-test-lb"
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}