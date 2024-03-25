data "aws_iam_roles" "sso_administrator" {
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
  name_regex = "^AWSReservedSSO_administrator_.*"
}