provider "aws" {
    region = var.region
}

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = var.subnet_cidr

  tags = {
    Name = var.subnet_name
  }
}

resource "aws_internet_gateway" "my-internet-gateway" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_route_table" "my-route-table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-internet-gateway.id
  }

  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "route_table_assoc" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.my-route-table.id
}

resource "aws_security_group" "webscraper-sg" {
  name        = var.security_group_name
  description = "Allow ssh inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my-vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.webscraper-sg.id
  description       = "SSH"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.webscraper-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "aws_instance" "webscraper_ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name        = var.key_name
  subnet_id       = aws_subnet.public-subnet.id
  security_groups = [aws_security_group.webscraper-sg.id]
  associate_public_ip_address = true

  user_data = file("${path.module}/user_data.sh")

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = var.ec2_name
  }
}

resource "aws_s3_bucket" "webscraper_output"{
  bucket = var.bucket_name
}

resource "aws_iam_role" "ec2_s3_role" {
  name = var.ec2_iam_role_name

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

resource "aws_iam_policy" "ec2_s3_policy" {
  name        = var.ec2_s3_policy_name
  description = "Allow EC2 to upload files to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::scraped_book_info/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.ec2_s3_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.ec2_instance_profile_name
  role = aws_iam_role.ec2_s3_role.name
}
