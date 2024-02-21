terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.global]
    }
  }
  required_version = ">= 1.0"
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "dnssec" {
  customer_master_key_spec = "ECC_NIST_P256"
  deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign",
          "kms:Verify",
        ],
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Resource = "*"
        Sid      = "Allow Route 53 DNSSEC Service",
      },
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
  provider = aws.global
}

resource "aws_route53_key_signing_key" "ksk" {
  hosted_zone_id             = var.zone.id
  key_management_service_arn = aws_kms_key.dnssec.arn
  name                       = var.name
}

resource "aws_route53_hosted_zone_dnssec" "enable" {
  depends_on     = [aws_route53_key_signing_key.ksk]
  hosted_zone_id = aws_route53_key_signing_key.ksk.hosted_zone_id
}
