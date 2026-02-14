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


