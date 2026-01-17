variable "name" { type = string }
variable "instance_type" { type = string }
variable "subnet_id" { type = string }
variable "vpc_security_group_ids" { type = list(string) }
variable "key_name" { 
  type = string 
  default = "" 
}

variable "provision_key_content" {
  description = "Content of the key to be provisioned onto the instance"
  type        = string
  default     = ""
}

variable "enable_provisioning" {
  description = "Whether to enable provisioning on this instance"
  type        = bool
  default     = false
}

variable "provision_key_path" {
  description = "Destination path for the provisioned key"
  type        = string
  default     = "/home/ec2-user/private-instances-key.pem"
}

variable "connection_private_key" {
  description = "Private key content used to SSH into the instance for provisioning"
  type        = string
  default     = ""
}

variable "bastion_host" {
  description = "Public IP of the bastion host (if needed for jump)"
  type        = string
  default     = ""
}

variable "bastion_private_key" {
  description = "Private key content for the bastion host"
  type        = string
  default     = ""
}

variable "bastion_user" {
  description = "User for the bastion host"
  type        = string
  default     = "ec2-user"
}
