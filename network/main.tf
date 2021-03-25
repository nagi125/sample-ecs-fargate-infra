variable "app_name" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

# PublicSubnets
variable "public_subnet_cidrs" {
  default = ["10.10.0.0/24", "10.10.1.0/24"]
}

# PrivateSubnets
variable "private_subnet_cidrs" {
  default = ["10.10.10.0/24", "10.10.11.0/24"]
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  # ECSをPublicSubnet上に配置する場合は必須
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.app_name
  }
}

# Subnet(Public)
resource "aws_subnet" "publics" {
  count = length(var.public_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  availability_zone = var.azs[count.index]
  cidr_block        = var.public_subnet_cidrs[count.index]

  tags = {
    Name = "${var.app_name}-public-${count.index}"
  }
}

# Subnet(Private)
resource "aws_subnet" "privates" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  availability_zone = var.azs[count.index]
  cidr_block        = var.private_subnet_cidrs[count.index]

  tags = {
    Name = "${var.app_name}-private-${count.index}"
  }
}

# Subnet(EC2)
resource "aws_subnet" "ec2" {
  cidr_block        = "10.10.100.0/24"
  availability_zone = "ap-northeast-1a"
  vpc_id            = aws_vpc.main.id

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-ec2"
  }
}


# IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.app_name
  }
}

# RouteTable(Public)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-public"
  }
}

# Route(Public)
resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.main.id
}

# RouteTableAssociation(Public)
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id = element(aws_subnet.publics.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# RouteTableAssociation(EC2)
resource "aws_route_table_association" "ec2" {
  subnet_id = aws_subnet.ec2.id
  route_table_id = aws_route_table.public.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.publics.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.privates.*.id
}

output "ec2_subnet_id" {
  value = aws_subnet.ec2.id
}
