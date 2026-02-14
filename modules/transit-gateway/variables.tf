variable "name" {
    description = "The name of the Transit Gateway"
    type        = string
}
variable "description" {
    description = "The description of the Transit Gateway"
    type        = string
    default     = "Managed by Terraform"
}
variable "amazon_side_asn" {
    description = "The private Autonomous System Number (ASN) for the Amazon side of a BGP session."
    type        = number
    default     = 64512
}
variable "enable_default_route_table_association" {
    description = "Enable default route table association"
    type        = bool
    default     = false  
}
variable "enable_default_route_table_propagation" {
    description = "Enable default route table propagation"
    type        = bool
    default     = false  
}
# map of vpc attachment to transit gateway
variable "vpc_attachments" {
    description = "Map of VPC attachments to the Transit Gateway"
    type = map(object({
        vpc_id     = string
        subnet_ids = list(string)
    }))
    default = {}
}
