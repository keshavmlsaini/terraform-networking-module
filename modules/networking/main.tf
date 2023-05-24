resource "aws_vpc" "main" {
  cidr_block           = var.vpc
  enable_dns_hostnames = true
  tags = {
    Name = "test"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.public_cidrs)
  cidr_block        = var.public_cidrs[count.index]
  availability_zone = data.aws_availability_zones.az.names[count.index]
  tags = {
    Name = "public - ${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.private_cidrs)
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = data.aws_availability_zones.az.names[count.index]
  tags = {
    Name = "private - ${count.index + 1}"
  }
}

# Create internet gateway and attach to VPC
resource "aws_internet_gateway" "gate" {
  vpc_id = aws_vpc.main.id
    tags = {
    Name = "test-igw"
  }
}

# Create route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gate.id
  }
   tags = {
    Name = "public-route-table"
  }
}

# Private route table resource definition
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
    route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "private-route-table"
  }
}

# Public route table association resource definition
resource "aws_route_table_association" "public_subnet_association" {
  count = length(var.public_cidrs)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

# Private route table association resource definition
resource "aws_route_table_association" "private_subnet_association" {
  count = length(var.private_cidrs)
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.id
}


resource "aws_eip" "nat_eip" {
  vpc = true
  #depends_on = [aws_internet_gateway.id]
}


# # NAT GW -----> this will create two Nat Gateway i want only one
# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat_eip.id
#     count = length(var.public_cidrs)
#   subnet_id      = aws_subnet.public.*.id[count.index]
#   tags = {
#     Name = "NAT-test"  
#   }
# }

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "NAT-test"
  }
}



