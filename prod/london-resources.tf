# VPCs - London

module "vpc_london_1" {
  source = "../modules/vpc"
  providers = {
    aws = aws.london
  }
  vpc_name   = "vpc-london-1"
  vpc_cidr   = "10.0.0.0/16"
  enable_igw = true
  enable_nat = true

  public_subnets = {
    "a" = { cidr = "10.0.0.0/24", az = "eu-west-2a" }
  }
  private_subnets = {
    "b" = { cidr = "10.0.1.0/24", az = "eu-west-2b" }
  }

  nat_public_subnet_key = "a"

}

module "vpc_london_2" {
  source = "../modules/vpc"
  providers = {
    aws = aws.london
  }
  vpc_name   = "vpc-london-2"
  vpc_cidr   = "11.0.0.0/16"
  enable_igw = false


  private_subnets = {
    "a" = { cidr = "11.0.0.0/24", az = "eu-west-2a" }
  }
}

#security Groups - London

module "public_SG_london" {
  source      = "../modules/security-group"
  providers   = { aws = aws.london }
  Name        = "public-SG-london"
  description = "Public security group for London VPC"
  vpc_id      = module.vpc_london_1.vpc_id
  ingress_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["0.0.0.0/0"], description = "ICMP access" },
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "SSH access" }
  ]
}

# Transit Gateway - London

module "london_tgw" {
  source    = "../modules/transit-gateway"
  providers = { aws = aws.london }

  name                                   = "london-tgw"
  description                            = "Transit Gateway for London region"
  amazon_side_asn                        = 64512
  enable_default_route_table_association = false
  enable_default_route_table_propagation = false
  vpc_attachments = {
    vpc_london_1 = {
      subnet_ids = concat(values(module.vpc_london_1.public_subnets_ids), values(module.vpc_london_1.private_subnets_ids))
      vpc_id     = module.vpc_london_1.vpc_id
    }
    vpc_london_2 = {
      subnet_ids = values(module.vpc_london_2.private_subnets_ids)
      vpc_id     = module.vpc_london_2.vpc_id
    }
  }
}
# london private route to tgw
resource "aws_route" "vpc_london_1_private_to_vpc_2" {
  provider               = aws.london
  for_each               = module.vpc_london_1.private_route_table_ids
  route_table_id         = each.value
  destination_cidr_block = module.vpc_london_2.vpc_cidr
  transit_gateway_id     = module.london_tgw.transit_gateway_id

}
resource "aws_route" "vpc_london_1_private_to_paris_vpc_1" {
  provider               = aws.london
  for_each               = module.vpc_london_1.private_route_table_ids
  route_table_id         = each.value
  destination_cidr_block = module.vpc_paris_1.vpc_cidr
  transit_gateway_id     = module.london_tgw.transit_gateway_id
  
}
resource "aws_route" "vpc_london_1_public_to_vpc_2" {
  provider               = aws.london
  for_each               = module.vpc_london_1.public_route_table_ids
  route_table_id         = each.value
  destination_cidr_block = module.vpc_london_2.vpc_cidr
  transit_gateway_id     = module.london_tgw.transit_gateway_id
}

resource "aws_route" "vpc_london_1_public_to_paris_vpc_1" {
  provider               = aws.london
  for_each               = module.vpc_london_1.public_route_table_ids
  route_table_id         = each.value
  destination_cidr_block = module.vpc_paris_1.vpc_cidr
  transit_gateway_id     = module.london_tgw.transit_gateway_id
}
resource "aws_route" "vpc_london_2_private_to_paris_vpc_1" {
  provider               = aws.london
  for_each               = module.vpc_london_2.private_route_table_ids
  route_table_id         = each.value
  destination_cidr_block = module.vpc_paris_1.vpc_cidr
  transit_gateway_id     = module.london_tgw.transit_gateway_id
}
resource "aws_route" "vpc_london_2_private_to_london_vpc_1" {
  provider               = aws.london
  for_each               = module.vpc_london_2.private_route_table_ids
  route_table_id         = each.value
  destination_cidr_block = module.vpc_london_1.vpc_cidr
  transit_gateway_id     = module.london_tgw.transit_gateway_id
  
}
# EC2 bastion - london

resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096

}
resource "aws_key_pair" "bastion" {
  provider   = aws.london
  key_name   = "bastion_key"
  public_key = tls_private_key.bastion.public_key_openssh
}
resource "local_file" "bastion_key" {
  content         = tls_private_key.bastion.private_key_pem
  filename        = "${path.module}/bastion_key.pem"
  file_permission = "0400"
}
module "ec2_bastion" {
  source    = "../modules/ec2"
  providers = { aws = aws.london }

  name                   = "bastion-vpc-london-1"
  instance_type          = "t3.micro"
  subnet_id              = module.vpc_london_1.public_subnets_ids["a"]
  vpc_security_group_ids = [module.public_SG_london.security_group_id]
  key_name               = aws_key_pair.bastion.key_name

  # Provisioning
  enable_provisioning    = true
  provision_key_content  = tls_private_key.private_instances.private_key_pem
  connection_private_key = tls_private_key.bastion.private_key_pem
}

  # private instances key pair
resource "tls_private_key" "private_instances" {
  algorithm = "RSA"
  rsa_bits  = 4096

}
resource "aws_key_pair" "private_instances" {
  provider   = aws.london
  key_name   = "private_instances_key"
  public_key = tls_private_key.private_instances.public_key_openssh
}
resource "local_file" "private_instances_key" {
  content         = tls_private_key.private_instances.private_key_pem
  filename        = "${path.module}/private_instances_key.pem"
  file_permission = "0400"
}
# private instances - london

module "ec2_london_private" {
  source    = "../modules/ec2"
  providers = { aws = aws.london }

  name                   = "private-instance-vpc-london-1"
  instance_type          = "t3.micro"
  subnet_id              = module.vpc_london_1.private_subnets_ids["b"]
  key_name               = aws_key_pair.private_instances.key_name
  vpc_security_group_ids = [module.public_SG_london.security_group_id]

  enable_provisioning = true

  connection_private_key = tls_private_key.private_instances.private_key_pem
  bastion_host           = module.ec2_bastion.public_ip
  bastion_private_key    = tls_private_key.bastion.private_key_pem
  provision_key_content  = tls_private_key.private_instances.private_key_pem

}

