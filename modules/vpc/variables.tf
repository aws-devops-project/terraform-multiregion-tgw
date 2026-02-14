variable "vpc_name" {
    description = "The name of the VPC"
    type        = string
}
variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type        = string
}

variable "public_subnets" {
    description = "Map of public subnet definitions keyed by suffix"
    type = map(object({  
        cidr = string
        az = string
    }))
    default = {}

}

variable "private_subnets" {
    description = "Map of private subnet definitions keyed by suffix"
    type        = map(object({
        cidr = string
        az = string
    }))
    default = {}
}

variable "enable_igw" { 
    default = false
    description = "Enable Internet Gateway"
    type        = bool
}

variable "enable_nat" {
    description = "Enable NAT Gateway for private subnets"
    type        = bool
    default     = false
  
}
variable "nat_allocation_id" {
    description = "The allocation ID for the Elastic IP to associate with the NAT Gateway"
    type        = string
    default     = ""
}
variable "nat_public_subnet_key" {
    description = "The key of the public subnet to deploy the NAT Gateway in"
    type        = string
    default     = ""
  
}


