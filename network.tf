resource "aws_vpc" "main" {
  cidr_block = var.vpc_info.vpc_cidr

  tags = {
    Name = "vijay"
  }
}
resource "aws_subnet" "subnets" {
  count = length(var.vpc_info.subnet_names)
  cidr_block = cidrsubnet(var.vpc_info.vpc_cidr, 8, count.index)
  availability_zone = "${var.region}${var.vpc_info.az[count.index]}"
  vpc_id = aws_vpc.main.id

  tags = {
    Name= var.vpc_info.subnet_names[count.index]
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "gw"
  }
  depends_on = [ aws_vpc.main ]
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private"
  }
}
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.main.id]
  }
  filter {
    name = "tag:Name"
    values = var.vpc_info.public_subnets
  }
}
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.main.id]
  }
  filter {
    name = "tag:Name"
    values = var.vpc_info.private_subnets
  }
}
resource "aws_route_table_association" "public" {
  count = length(data.aws_subnets.public.ids)
  subnet_id      = data.aws_subnets.public.ids[count.index]
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count = length(data.aws_subnets.private.ids)
  subnet_id      = data.aws_subnets.private.ids[count.index]
  route_table_id = aws_route_table.private.id
}