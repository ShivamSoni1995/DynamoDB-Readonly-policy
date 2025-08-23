provider "aws" {
  region = "us-east-1"   # Change if needed
}

# --------------------------
# DynamoDB Table
# --------------------------
resource "aws_dynamodb_table" "my_table" {
  name         = "my-app-table"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "MyAppTable"
  }
}

# --------------------------
# IAM Role for EC2
# --------------------------
resource "aws_iam_role" "ec2_role" {
  name = "EC2DynamoDBReadRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# --------------------------
# IAM Policy (Read-only DynamoDB)
# --------------------------
resource "aws_iam_policy" "dynamodb_read_policy" {
  name = "DynamoDBReadOnlySpecificTable"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query"
        ],
        Resource = aws_dynamodb_table.my_table.arn
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.dynamodb_read_policy.arn
}

# --------------------------
# Instance Profile (needed to attach IAM Role to EC2)
# --------------------------
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2DynamoDBProfile"
  role = aws_iam_role.ec2_role.name
}

# --------------------------
# Security Group
# --------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow SSH"
  vpc_id      = "default" # if you are using default VPC

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict in production!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --------------------------
# EC2 Instance
# --------------------------
resource "aws_instance" "ec2" {
  ami           = "ami-08c40ec9ead489470" # Amazon Linux 2 in us-east-1
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  security_groups      = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "EC2-DynamoDB-Demo"
  }
}
