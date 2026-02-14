variable "requester_transit_gateway_id" {
    type = string
    description = "TGW ID of the requester"
}
variable "accepter_transit_gateway_id" {
    type = string
    description = "TGW ID of the accepter"
}
variable "peer_account_id" {
    type = string
    description = "AWS Account ID of the accepter"
}
variable "peer_region" {
    type = string
    description = "AWS Region of the accepter"
}
