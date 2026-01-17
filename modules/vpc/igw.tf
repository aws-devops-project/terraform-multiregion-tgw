resource "aws_internet_gateway" "this" {
  count = var.enable_igw ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "igw-${var.vpc_name}"
  }
}
