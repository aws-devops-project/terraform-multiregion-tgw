variable "Name" {
  description = "security group configuration"
  type        = string
    
}
variable "description" {
  description = "security group description"
  type        = string
  default = "Managed by Terraform"
  
}
variable "vpc_id" {
  description = "VPC_ID"
  type        = string
  
}
variable "ingress_rules" {
  description = "ingress rules"
  type        = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string)
  }))
  default = [] 
}
variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = list(string) 
  }))  
  default = [
    {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [ "0.0.0.0/0" ]
    }
  ]
}

