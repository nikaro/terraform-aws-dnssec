resource "aws_route53_zone" "example_net" {
  name = "example.net"
}

module "dnssec_example_net" {
  source  = "nikaro/dnssec/aws"
  version = "1.0.0"
  zone    = aws_route53_zone.example_net
  name    = "example_net"
}
