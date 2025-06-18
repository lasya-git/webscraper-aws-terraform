variable "region" {
    description = "aws region"
    type = string
}

variable "vpc_cidr" {
    description = "CIDR block for the vpc"
    type = string
}

variable "vpc_name" {
    description = "name of vpc"
    type = string
}

variable "subnet_cidr" {
    description = "CIDR block for the public subnet"
    type = string
}

variable "subnet_name" {
    description = "name of public subnet"
    type = string
}

variable "igw_name" {
    description = "name of internet gateway"
    type = string
}

variable "route_table_name" {
    description = "name of route table"
    type = string
}

variable "ami" {
    description = "ami of ec2 instance"
    type = string
}

variable "instance_type" {
    description = "type of ec2 instance"
    type = string
}

variable "ec2_name" {
    description = "name of ec2 instance"
    type = string
}

variable "security_group_name" {
    description = "name of security group"
    type = string
}

variable "bucket_name" {
    description = "name of s3 bucket"
    type = string
}

variable "ec2_iam_role_name" {
    description = "name of iam ec2 role"
    type = string
}

variable "ec2_s3_policy_name" {
    description = "name of iam ec2 s3 put policy"
    type = string
}

variable "ec2_instance_profile_name" {
    description = "name of ec2 instance profile"
    type = string
}

variable "key_name" {
  description = "Name of the existing EC2 key pair"
  type = string
}