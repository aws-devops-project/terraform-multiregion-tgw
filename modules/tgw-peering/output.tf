output "peering_attachment_id" {
    value = aws_ec2_transit_gateway_peering_attachment.this.id
    description = "The ID of the Transit Gateway Peering Attachment"
    depends_on = [ aws_ec2_transit_gateway_peering_attachment.this ]
     
}