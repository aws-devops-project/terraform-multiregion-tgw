# Public Route Table (only if IGW enabled and public subnets exist)
resource "aws_route_table" "public" {
  count = var.enable_igw ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "rt-${var.vpc_name}-public"
  }
}

resource "aws_route" "public_internet_access" {
  count = var.enable_igw ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  for_each = var.enable_igw ? var.public_subnets : {}

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[0].id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "rt-${var.vpc_name}-private"
  }
}

resource "aws_route_table_association" "private" {
  for_each = var.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private.id
}
