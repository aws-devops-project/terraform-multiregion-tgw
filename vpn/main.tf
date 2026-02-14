# london aws side network
module "london_vpc_A" {
  source    = "../modules/vpc"
  providers = { aws = aws.london }
  vpc_name = "london-vpc-a"
  vpc_cidr = "10.100.0.0/16"
  enable_igw = false
  enable_nat = false
    private_subnets = {
        "a" = { cidr = "10.100.0.0/16", az = "eu-west-2a" }
    }
}

module "private_SG" {
    source      = "../modules/security-group"
    providers   = { aws = aws.london }
    Name        = "private-SG-london"
    description = "Private security group for London VPC"
    vpc_id      = module.london_vpc_A.vpc_id
    ingress_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["0.0.0.0/0"], description = "ICMP access" },
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "SSH access" }
  ]
}
# private instances key pair
resource "tls_private_key" "private_instances" {
    algorithm = "RSA"
    rsa_bits  = 4096  
}
resource "aws_key_pair" "private_instances" {
    provider   = aws.london
    key_name   = "private-instances-key"
    public_key = tls_private_key.private_instances.public_key_openssh
}
resource "local_file" "private_instances_key" {
    content  = tls_private_key.private_instances.private_key_pem
    filename = "${path.module}/private_instances_key.pem"
    file_permission = "0400"  
}
#private instances - london
module "ec2_london_private" {
  source    = "../modules/ec2"
  providers = { aws = aws.london }

  name = "ec2-london-private"
  instance_type = "t3.micro"
  subnet_id    = module.london_vpc_A.private_subnets_ids["a"]
  vpc_security_group_ids = [module.private_SG.security_group_id]
  key_name = aws_key_pair.private_instances.key_name
  enable_provisioning = false
}
