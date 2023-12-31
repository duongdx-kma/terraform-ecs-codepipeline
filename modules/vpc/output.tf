output "vpc_id" {
  value = aws_vpc.main.id
  description = "The ID of the VPC"
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
  description = "The cidr_block of the VPC"
}

output "private_subnets" {
  value = aws_subnet.main-private-subnet[*].id
  description = "List ID of the private subnets"
}

output "public_subnets" {
  value = aws_subnet.main-public-subnet[*].id
  description = "List ID of the public subnets"
}

output "private-route-table-id" {
  value = aws_route_table.main-private-route.id
}