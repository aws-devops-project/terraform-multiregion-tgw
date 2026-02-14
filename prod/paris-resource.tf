# paris - vpc
module "vpc_paris_1" {
  source     = "../modules/vpc"
  providers  = { aws = aws.paris }
  vpc_name   = "vpc-paris-1"
  vpc_cidr   = "12.0.0.0/16"
  enable_igw = false
  enable_nat = false

  private_subnets = {
    "a" = { cidr = "12.0.1.0/24", az = "eu-west-3a" }
  }
}

# paris - security group
module "private_SG_paris" {
  source      = "../modules/security-group"
  providers   = { aws = aws.paris }
  Name        = "private-SG-paris"
  description = "Private security group for Paris VPC"
  vpc_id      = module.vpc_paris_1.vpc_id
  ingress_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["0.0.0.0/0"], description = "ICMP access" },
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "SSH access" }
  ]
}

# Transit Gateway - Paris
module "paris_tgw" {
  source    = "../modules/transit-gateway"
  providers = { aws = aws.paris }

  name                                   = "paris-tgw"
  description                            = "Transit Gateway for Paris region"
  amazon_side_asn                        = 64513
  enable_default_route_table_association = false
  enable_default_route_table_propagation = false
  vpc_attachments = {
    paris_vpc_1 = {
      vpc_id     = module.vpc_paris_1.vpc_id
      subnet_ids = values(module.vpc_paris_1.private_subnets_ids)
    }
  }

}
# paris vpc route to tgw
resource "aws_route" "vpc_paris_1_private_to_vpc_london_1" {
  provider       = aws.paris
  for_each       = module.vpc_paris_1.private_route_table_ids
  route_table_id = each.value

  destination_cidr_block = module.vpc_london_1.vpc_cidr
  transit_gateway_id     = module.paris_tgw.transit_gateway_id

}
resource "aws_route" "vpc_paris_1_private_to_vpc_london_2" {
  provider               = aws.paris
  for_each               = module.vpc_paris_1.private_route_table_ids
  route_table_id         = each.value
  destination_cidr_block = module.vpc_london_2.vpc_cidr
  transit_gateway_id     = module.paris_tgw.transit_gateway_id

}

# TGW peering between london and paris

data "aws_caller_identity" "london" {
  provider = aws.london
}
module "tgw_peering_london_paris" {
  source = "../modules/tgw-peering"
  providers = {
    aws.requester = aws.london
    aws.accepter  = aws.paris
  }
  requester_transit_gateway_id = module.london_tgw.transit_gateway_id
  accepter_transit_gateway_id  = module.paris_tgw.transit_gateway_id
  peer_account_id              = data.aws_caller_identity.london.account_id
  peer_region                  = "eu-west-3"

}

# TGW peering association
resource "aws_ec2_transit_gateway_route_table_association" "peering_london" {
  provider                       = aws.london
  transit_gateway_route_table_id = module.london_tgw.transit_gateway_route_table_id
  transit_gateway_attachment_id  = module.tgw_peering_london_paris.peering_attachment_id
  depends_on                     = [module.tgw_peering_london_paris]
}


resource "aws_ec2_transit_gateway_route_table_association" "peering_paris" {
  provider                       = aws.paris
  transit_gateway_route_table_id = module.paris_tgw.transit_gateway_route_table_id
  transit_gateway_attachment_id  = module.tgw_peering_london_paris.peering_attachment_id
  depends_on                     = [module.tgw_peering_london_paris]

}
# add routes to peering in tgw route tables (static routing)
resource "aws_ec2_transit_gateway_route" "london_to_paris" {
  provider                       = aws.london
  transit_gateway_route_table_id = module.london_tgw.transit_gateway_route_table_id
  destination_cidr_block         = module.vpc_paris_1.vpc_cidr
  transit_gateway_attachment_id  = module.tgw_peering_london_paris.peering_attachment_id
  depends_on                     = [module.tgw_peering_london_paris]

}
resource "aws_ec2_transit_gateway_route" "paris_to_london_vpc1" {
  provider                       = aws.paris
  transit_gateway_route_table_id = module.paris_tgw.transit_gateway_route_table_id
  destination_cidr_block         = module.vpc_london_1.vpc_cidr
  transit_gateway_attachment_id  = module.tgw_peering_london_paris.peering_attachment_id
  depends_on                     = [module.tgw_peering_london_paris]
}
resource "aws_ec2_transit_gateway_route" "paris_to_london_vpc2" {
  provider                       = aws.paris
  transit_gateway_route_table_id = module.paris_tgw.transit_gateway_route_table_id
  destination_cidr_block         = module.vpc_london_2.vpc_cidr
  transit_gateway_attachment_id  = module.tgw_peering_london_paris.peering_attachment_id
  depends_on                     = [module.tgw_peering_london_paris]
}

# private key for private ec2 in paris
resource "aws_key_pair" "private_ec2_paris" {
  provider   = aws.paris
  key_name   = "private_ec2_key_paris"
  public_key = tls_private_key.private_instances.public_key_openssh
}

# private ec2 in paris
module "ec2_private_paris" {
  source    = "../modules/ec2"
  providers = { aws = aws.paris }

  name                = "private-ec2-paris"
  instance_type       = "t3.micro"
  subnet_id         = module.vpc_paris_1.private_subnets_ids["a"]
  vpc_security_group_ids = [module.private_SG_paris.security_group_id]
  key_name            = aws_key_pair.private_ec2_paris.key_name

  # Provisioning
  enable_provisioning    = true
  provision_key_content  = tls_private_key.private_instances.private_key_pem
  connection_private_key = tls_private_key.private_instances.private_key_pem
  bastion_host =  module.ec2_bastion.public_ip
  bastion_user = "ec2-user"
  bastion_private_key = tls_private_key.bastion.private_key_pem

  depends_on = [ module.ec2_bastion ]
}
