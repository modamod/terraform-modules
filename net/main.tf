

data "aws_availability_zones" "azs" {

}
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.tags
}

resource "aws_subnet" "public_subnets" {
  count             = var.create_public_subnets ? length(var.azs) : 0
  availability_zone = var.azs[count.index]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 4, count.index)
}

resource "aws_internet_gateway" "igw" {
  count  = var.create_public_subnets ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags   = var.tags
}

resource "aws_route_table" "public_route_table" {
  count  = var.create_public_subnets ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags   = var.tags
}

resource "aws_route" "public_route" {
  count                  = var.create_public_subnets ? 1 : 0
  route_table_id         = aws_route_table.public_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw[0].id
}


resource "aws_route_table_association" "public_route_table_association" {
  count          = var.create_public_subnets ? length(var.azs) : 0
  route_table_id = aws_route_table.public_route_table[0].id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

resource "aws_subnet" "private_subnets" {
  count             = var.create_private_subnets ? length(var.azs) : 0
  availability_zone = var.azs[count.index]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 4, length(var.azs) + count.index)
  tags              = var.tags
}

resource "aws_eip" "ngw_eip" {
  vpc = true
  tags = var.tags
}

resource "aws_nat_gateway" "ngw" {
  count     = var.create_nat_gateway && var.create_public_subnets && var.create_private_subnets ? 1 : 0
  subnet_id = aws_subnet.public_subnets[0].id
  allocation_id = aws_eip.ngw_eip.allocation_id
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_route_table" "private_route_table" {
  count  = var.create_private_subnets && var.create_nat_gateway ? length(var.azs) : 0
  vpc_id = aws_vpc.vpc.id
  tags   = var.tags
}

resource "aws_route" "private_route" {
  count                  = var.create_private_subnets && var.create_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.ngw[0].id
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = var.create_private_subnets && var.create_nat_gateway ? length(var.azs) : 0
  route_table_id = aws_route_table.private_route_table[0].id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}
