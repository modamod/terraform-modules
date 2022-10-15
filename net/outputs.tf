output "private_subnets" {
  value = aws_subnet.private_subnets
}

output "public_subnets" {
  value = aws_subnet.public_subnets
}

output "vpc" {
  value = aws_vpc.vpc
}
