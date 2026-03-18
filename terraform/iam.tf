

# EC2 ROLE (Required for EC2 to pull images from ECR)


resource "aws_iam_role" "ec2_role" {
  name = "ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ecr_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# DEVOPS ENGINEER ROLE (Full Infrastructure Control)


resource "aws_iam_role" "devops_role" {
  name = "devops-engineer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "*"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "devops_admin_attach" {
  role       = aws_iam_role.devops_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


# DEVELOPER ROLE (Limited Deployment Access)


resource "aws_iam_policy" "developer_policy" {
  name        = "developer-limited-policy"
  description = "Limited access for application developers"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:*",
          "ec2:Describe*",
          "elasticloadbalancing:Describe*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "developer_role" {
  name = "developer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "*"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "developer_attach" {
  role       = aws_iam_role.developer_role.name
  policy_arn = aws_iam_policy.developer_policy.arn
}


# MONITORING USER ROLE (Read-Only Access)


resource "aws_iam_role" "monitoring_role" {
  name = "monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "*"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "monitoring_readonly_attach" {
  role       = aws_iam_role.monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}