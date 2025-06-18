output "instance_public_ip" {
  value = aws_instance.webscraper_ec2.public_ip
}