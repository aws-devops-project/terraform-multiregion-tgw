output "vpc_id" {
  description = "VPC_ID"
  value = aws_vpc.this.id
}

output "public_subnets_ids" {
  value = {
    for key, subnet in aws_subnet.public : key => subnet.id
  }
}
output "private_subnets_ids" {
  value = {
    for key, subnet in aws_subnet.private : key => subnet.id
  }
}
output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value = var.enable_igw ? aws_internet_gateway.this[0].id : null
}
output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
  
}
output "public_route_table_ids" {
  description = "Public Route Table IDs"
  value = var.enable_igw ? { for key, rt in aws_route_table.public : key => rt.id } : {}
  
}
output "private_route_table_ids" {
  description = "Private route table IDs"
    value = {
      main = aws_route_table.private.id
    }
}
