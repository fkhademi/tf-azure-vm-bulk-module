data "aws_route53_zone" "domain_name" {
  name         = var.domain_name
  private_zone = false
}