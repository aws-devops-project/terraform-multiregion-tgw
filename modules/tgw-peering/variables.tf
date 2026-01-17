variable "requestor_tgw_id" {
  description = "TGW ID of the requester"
  type        = string
}

variable "accepter_tgw_id" {
  description = "TGW ID of the accepter"
  type        = string
}

variable "peer_region" {
  description = "Region of the accepter TGW"
  type        = string
}

variable "peer_account_id" {
  description = "Account ID of the accepter TGW"
  type        = string
}
