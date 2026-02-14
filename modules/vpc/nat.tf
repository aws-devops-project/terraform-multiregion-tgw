#NAT Gateway for private subnets
resource "aws_eip" "nat" {
    count = var.enable_nat ? 1 : 0

    domain = "vpc"
    tags = {Name = "${var.vpc_name}-nat-eip"}  
}


resource "aws_nat_gateway" "this" {
    count = var.enable_nat ? 1 : 0

    allocation_id = aws_eip.nat[0].id
    subnet_id = aws_subnet.public[var.nat_public_subnet_key].id

    tags = {Name = "${var.vpc_name}-nat"}  

    depends_on = [ aws_internet_gateway.this ]
}
