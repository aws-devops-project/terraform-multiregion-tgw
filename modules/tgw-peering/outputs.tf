output "peering_attachment_id" {
  value = aws_ec2_transit_gateway_peering_attachment.this.id
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this]
}
