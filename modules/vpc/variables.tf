variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Map of public subnets with CIDR and AZ"
  type        = map(object({
    cidr = string
    az   = string
  }))
  default = {}
}

variable "private_subnets" {
  description = "Map of private subnets with CIDR and AZ"
  type        = map(object({
    cidr = string
    az   = string
  }))
  default = {}
}

variable "enable_igw" {
  description = "Enable Internet Gateway"
  type        = bool
  default     = false
}
