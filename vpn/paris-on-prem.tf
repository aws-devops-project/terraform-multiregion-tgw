# paris on-prem setup
module "paris_on_prem_vpc" {
    source = "../modules/vpc"
    providers   = { aws = aws.paris}
    vpc_name = "paris-on-prem-vpc"
    vpc_cidr = "10.200.0.0/16"
    enable_igw = true
    enable_nat = false
    public_subnets = {
        "a" = { cidr = "10.200.0.0/24", az = "eu-west-3a" }
        }
}
#security group for on-prem vpc
module "paris_on_prem_SG" {
    source      = "../modules/security-group"
    providers   = { aws = aws.paris}
    Name        = "paris-on-prem-SG"
    description = "Security group for Paris on-prem VPC"
    vpc_id      = module.paris_on_prem_vpc.vpc_id
 
    ingress_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["0.0.0.0/0"], description = "ICMP access" },
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "SSH access" }
  ]
  
}

# EC2 instance in Paris on-prem VPC
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096

}
resource "aws_key_pair" "bastion" {
  provider   = aws.paris
  key_name   = "bastion_key"
  public_key = tls_private_key.bastion.public_key_openssh
}
resource "local_file" "bastion_key" {
  content         = tls_private_key.bastion.private_key_pem
  filename        = "${path.module}/bastion_key.pem"
  file_permission = "0400"
}
module "ec2_paris_on_prem" {
    source = "../modules/ec2"
    providers   = { aws = aws.paris}
    name = "ec2-openswarn-router"
    instance_type = "t3.micro"
    subnet_id    = module.paris_on_prem_vpc.public_subnets_ids["a"]
    vpc_security_group_ids = [module.paris_on_prem_SG.security_group_id]
   
    enable_provisioning = true
    provision_key_content  = tls_private_key.bastion.private_key_pem
    connection_private_key = tls_private_key.bastion.private_key_pem
    key_name = aws_key_pair.bastion.key_name
    bastion_host = module.ec2_paris_on_prem.public_ip
    bastion_private_key = tls_private_key.bastion.private_key_pem

}