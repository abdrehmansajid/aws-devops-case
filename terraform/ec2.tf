resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_launch_template" "app_lt" {
  name_prefix   = "fastapi-lt"
  image_id      = "ami-053b0d53c279acc90"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
apt update -y
apt install -y docker.io awscli
systemctl start docker
systemctl enable docker

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 634541169888.dkr.ecr.us-east-1.amazonaws.com

docker pull 634541169888.dkr.ecr.us-east-1.amazonaws.com/fastapi-app:latest

docker run -d -p 80:8000 \
  -e ENVIRONMENT=production \
  -e PROJECT_NAME="FastAPI App" \
  -e POSTGRES_SERVER="${aws_db_instance.postgres.address}" \
  -e POSTGRES_PORT="5432" \
  -e POSTGRES_USER="dbadmin" \
  -e POSTGRES_PASSWORD="StrongPassword123!" \
  -e POSTGRES_DB="app" \
  -e FIRST_SUPERUSER="admin@example.com" \
  -e FIRST_SUPERUSER_PASSWORD="Admin123!" \
  -e BACKEND_CORS_ORIGINS='["http://fastapi-frontend-abdulrehman-2026.s3-website-us-east-1.amazonaws.com"]' \
  634541169888.dkr.ecr.us-east-1.amazonaws.com/fastapi-app:latest \
  bash -c "alembic upgrade head && fastapi run"
EOF
  )
}
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 2
  vpc_zone_identifier  = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  health_check_type = "ELB"
}