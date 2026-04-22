########################################
# VPC (MAIN NETWORK)
########################################
# This creates your main network in AWS.
# Everything (EKS, Jenkins, etc.) lives inside this VPC.

resource "aws_vpc" "main" {

  # IP range for the VPC
  cidr_block = var.vpc_cidr

  # Enable internal DNS (needed for EKS + services)
  enable_dns_support = true

  # Enable DNS hostnames (needed for public endpoints)
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 VPC"
  })
}

########################################
# INTERNET GATEWAY
########################################
# Allows public subnets to access the internet

resource "aws_internet_gateway" "main" {

  # Attach to VPC
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 Internet Gateway"
  })
}

########################################
# PUBLIC SUBNETS
########################################
# Used for:
# - Jenkins server
# - ALB (later)

resource "aws_subnet" "public" {

  count = length(var.public_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  # CIDR block for each subnet
  cidr_block = var.public_subnet_cidrs[count.index]

  # Spread across AZs
  availability_zone = data.aws_availability_zones.available.names[count.index]

  # Automatically assign public IPs
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 Public Subnet ${count.index + 1}"

    # Required for ALB later
    "kubernetes.io/role/elb" = "1"
  })
}

########################################
# PRIVATE SUBNETS
########################################
# Used for:
# - EKS worker nodes (more secure)

resource "aws_subnet" "private" {

  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  cidr_block = var.private_subnet_cidrs[count.index]

  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 Private Subnet ${count.index + 1}"

    # Required for internal load balancers
    "kubernetes.io/role/internal-elb" = "1"
  })
}

########################################
# ELASTIC IP (FOR NAT)
########################################
# Static public IP used by NAT Gateway

resource "aws_eip" "nat" {

  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 NAT EIP"
  })
}

########################################
# NAT GATEWAY
########################################
# Allows private subnets to access the internet
# (for updates, pulling Docker images, etc.)

resource "aws_nat_gateway" "main" {

  allocation_id = aws_eip.nat.id

  # Must be placed in a PUBLIC subnet
  subnet_id = aws_subnet.public[0].id

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 NAT Gateway"
  })

  depends_on = [aws_internet_gateway.main]
}

########################################
# PUBLIC ROUTE TABLE
########################################
# Controls routing for public subnets

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 Public Route Table"
  })
}

########################################
# PUBLIC ROUTE TO INTERNET
########################################
# Sends all traffic to the Internet Gateway

resource "aws_route" "public_internet_access" {

  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.main.id
}

########################################
# ASSOCIATE PUBLIC SUBNETS
########################################
# Links public subnets to public route table

resource "aws_route_table_association" "public" {

  count = length(aws_subnet.public)

  subnet_id = aws_subnet.public[count.index].id

  route_table_id = aws_route_table.public.id
}

########################################
# PRIVATE ROUTE TABLE
########################################
# Controls routing for private subnets

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "Tech Challenge 2 Private Route Table"
  })
}

########################################
# PRIVATE ROUTE TO NAT
########################################
# Allows private subnets to access the internet
# through the NAT Gateway

resource "aws_route" "private_nat_access" {

  route_table_id = aws_route_table.private.id

  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.main.id
}

########################################
# ASSOCIATE PRIVATE SUBNETS
########################################
# Links private subnets to private route table

resource "aws_route_table_association" "private" {

  count = length(aws_subnet.private)

  subnet_id = aws_subnet.private[count.index].id

  route_table_id = aws_route_table.private.id
}