output "transit_gateway_id" {
    description = "The ID of the Transit Gateway"
    value       = aws_ec2_transit_gateway.this.id  
}
output "transit_gateway_route_table_id" {
    description = "The ID of the Transit Gateway Route Table"
    value       = aws_ec2_transit_gateway_route_table.this.id  
}
output "transit_gateway_attachments" {
  value = aws_ec2_transit_gateway_vpc_attachment.this
}