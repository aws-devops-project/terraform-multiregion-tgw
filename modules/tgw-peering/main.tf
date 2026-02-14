resource "aws_ec2_transit_gateway_peering_attachment" "this" {
    provider = aws.requester
    peer_account_id = var.peer_account_id
    peer_region = var.peer_region
    peer_transit_gateway_id = var.accepter_transit_gateway_id
    transit_gateway_id = var.requester_transit_gateway_id

    tags = { Name = "tgw-peering-attchment-${var.requester_transit_gateway_id}-to-${var.accepter_transit_gateway_id}"}

}
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this" {
    provider = aws.accepter
    transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this.id

    tags = {
        name = " twg-peering-accepter"
    } 
}

