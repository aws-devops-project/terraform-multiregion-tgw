resource "aws_route_table" "public" {
    count = var.enable_igw ? 1 : 0
    vpc_id = aws_vpc.this.id
    tags = {Name = "${var.vpc_name}-public-rt"}

}

resource "aws_route" "public_internet_access" {
    count = var.enable_igw ? 1 : 0

    route_table_id         = aws_route_table.public[0].id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.this[0].id   

}
resource "aws_route_table_association" "public_subnets" {
    for_each = var.enable_igw ? var.public_subnets : {}

    subnet_id      = aws_subnet.public[each.key].id 
    route_table_id = aws_route_table.public[0].id
}
#private route table and routes 
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.this.id
    tags = {Name = "${var.vpc_name}-private-rt"}
}
resource "aws_route_table_association" "private_subnets" {
    for_each = var.private_subnets

    subnet_id      = aws_subnet.private[each.key].id 
    route_table_id = aws_route_table.private.id
}

# NAT Gateway route for private subnets
resource "aws_route" "private_nat_gateway_access" {
    count = var.enable_nat ? 1 : 0

    route_table_id         = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.this[0].id
}
