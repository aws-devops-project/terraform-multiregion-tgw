variable "name" {type = string}
variable "description" {
    type = string 
    default = ""
}
variable "instance_type" {type = string }
variable "subnet_id" {type = string}
variable "vpc_security_group_ids" {type = list(string) }
variable "key_name" { type = string }
variable "enable_provisioning" {
    type = bool
    default = false 
}
variable "connection_private_key" {
    type = string
    default = " "  
}
variable "bastion_host" {
    description = " Public IP of the bastion host "
    type = string
    default = ""
}
variable "bastion_user" {
    description = "user for bastion host"
    type = string
    default = ""
}
  
variable "bastion_private_key" {
    type = string
    default = ""
    description = "Private key content for the bastion host"
}

variable "provision_key_path" {
    type = string
    default     = "/home/ec2-user/private-instances-key.pem"
    description = "Destination path for the provisioned key"  
}

variable "provision_key_content" {
    type = string
    default = ""
    description = "Private key content used to SSH into the instance for provisioning"
}

