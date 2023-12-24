resource "aws_vpc" "main" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = merge({Name = "${var.env}-main-vpc"}, var.tags)
}

#############################################################################
# Subnets
resource "aws_subnet" "main-public-subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = element(var.azs, count.index)

  tags = merge({Name = "${var.env}-pubic-${element(var.azs, count.index)}"}, var.tags)
}

resource "aws_subnet" "main-private-subnet" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  map_public_ip_on_launch = "false"
  availability_zone       = element(var.azs, count.index)

  tags = merge({Name = "${var.env}-private-${element(var.azs, count.index)}"}, var.tags)
}

#############################################################################
# internet gateway
resource "aws_internet_gateway" "main-gateway" {
  vpc_id = aws_vpc.main.id

  tags = merge({Name = "${var.env}-main-gateway"}, var.tags)
}
#############################################################################
# public route table
resource "aws_route_table" "main-public-route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-gateway.id
  }

  tags = merge({Name = "${var.env}-main-public-route"}, var.tags)
}

#############################################################################
# route associations public subnet
resource "aws_route_table_association" "main-public-associate" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.main-public-subnet[*].id, count.index)
  route_table_id = aws_route_table.main-public-route.id
}

# private route table
resource "aws_route_table" "main-private-route" {
  vpc_id = aws_vpc.main.id

  tags = merge({Name = "${var.env}-main-private-route"}, var.tags)
}

#############################################################################
# route associations private subnet
resource "aws_route_table_association" "main-private-associate" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.main-private-subnet[*].id, count.index)
  route_table_id = aws_route_table.main-private-route.id
}
