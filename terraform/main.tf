provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
resource "aws_iam_policy" "monitoring_read_only" {
  name        = "monitoring-read-only"
  description = "Read-only access to CloudWatch and EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:*",
          "ec2:Describe*"
        ]
        Resource = "*"
      }
    ]
  })
}