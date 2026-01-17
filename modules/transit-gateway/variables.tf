variable "name" {
  description = "Name of the Transit Gateway"
  type        = string
}

variable "description" {
  description = "Description"
  type        = string
  default     = "TGW"
}

variable "amazon_side_asn" {
  description = "Private ASN for the Amazon side"
  type        = number
  default     = 64512
}

variable "vpc_attachments" {
  description = "Map of VPC details to attach to TGW"
  type = map(object({
    vpc_id     = string
    subnet_ids = list(string)
  }))
  default = {}
}

variable "enable_default_route_table_association" {
  type    = bool
  default = false
}

variable "enable_default_route_table_propagation" {
  type    = bool
  default = false
}
