################################################################################
# VPCs - London
################################################################################

module "vpc_london_1" {
  source = "../../modules/vpc"
  providers = {
    aws = aws.london
  }

  vpc_name = "vpc-london-1"
  vpc_cidr = "10.0.0.0/16"
  enable_igw = true

  public_subnets = {
    "a" = { cidr = "10.0.1.0/24", az = "eu-west-2a" }
  }
  private_subnets = {
    "b" = { cidr = "10.0.2.0/24", az = "eu-west-2b" }
  }
}

################################################################################
# VPCs - Paris
################################################################################

module "vpc_paris_2" {
  source = "../../modules/vpc"
  providers = {
    aws = aws.paris
  }

  vpc_name = "vpc-paris-2"
  vpc_cidr = "11.0.0.0/16"
  enable_igw = false

  private_subnets = {
    "a" = { cidr = "11.0.1.0/24", az = "eu-west-3a" }
  }
}

module "vpc_paris_3" {
  source = "../../modules/vpc"
  providers = {
    aws = aws.paris
  }

  vpc_name = "vpc-paris-3"
  vpc_cidr = "12.0.0.0/16"
  enable_igw = false

  private_subnets = {
    "a" = { cidr = "12.0.1.0/24", az = "eu-west-3a" }
  }
}

################################################################################
# Security Groups
################################################################################

module "sg_public_vpc1" {
  source = "../../modules/security-group"
  providers = { aws = aws.london }

  name        = "secgroup-vpc-london-1-public"
  description = "Allow SSH/HTTP"
  vpc_id      = module.vpc_london_1.vpc_id

  ingress_rules = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["11.0.0.0/16", "12.0.0.0/16"] },
  ]
}

module "sg_private_vpc1" {
  source = "../../modules/security-group"
  providers = { aws = aws.london }

  name        = "secgroup-vpc-london-1-private"
  description = "Private traffic"
  vpc_id      = module.vpc_london_1.vpc_id

  ingress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["10.0.0.0/16"] }, # Local VPC
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["11.0.0.0/16", "12.0.0.0/16"] }, # Remote SSH
    { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["11.0.0.0/16", "12.0.0.0/16"] } # Remote ICMP
  ]
}

module "sg_vpc_paris_2" {
  source = "../../modules/security-group"
  providers = { aws = aws.paris }

  name        = "secgroup-vpc-paris-2-private"
  description = "Private traffic"
  vpc_id      = module.vpc_paris_2.vpc_id

  ingress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["11.0.0.0/16"] }, # Local VPC
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.0.0.0/16", "12.0.0.0/16"] }, # Remote SSH
    { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["10.0.0.0/16", "12.0.0.0/16"] } # Remote ICMP
  ]
}
module "sg_vpc_paris_3" {
  source = "../../modules/security-group"
  providers = { aws = aws.paris }

  name        = "secgroup-vpc-paris-3-private"
  description = "Private traffic"
  vpc_id      = module.vpc_paris_3.vpc_id

  ingress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["12.0.0.0/16"] }, # Local VPC
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.0.0.0/16", "11.0.0.0/16"] }, # Remote SSH
    { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["10.0.0.0/16", "11.0.0.0/16"] } # Remote ICMP
  ]
}

################################################################################
# Transit Gateway - London
################################################################################

module "tgw_london" {
  source = "../../modules/transit-gateway"
  providers = { aws = aws.london }

  name = "tgw-london"
  vpc_attachments = {
    vpc1 = {
      vpc_id     = module.vpc_london_1.vpc_id
      subnet_ids = concat(module.vpc_london_1.public_subnet_ids, module.vpc_london_1.private_subnet_ids)
    }
  }
}

################################################################################
# Transit Gateway - Paris
################################################################################

module "tgw_paris" {
  source = "../../modules/transit-gateway"
  providers = { aws = aws.paris }

  name = "tgw-paris"
  vpc_attachments = {
    vpc2 = {
      vpc_id     = module.vpc_paris_2.vpc_id
      subnet_ids = module.vpc_paris_2.private_subnet_ids
    }
    vpc3 = {
      vpc_id     = module.vpc_paris_3.vpc_id
      subnet_ids = module.vpc_paris_3.private_subnet_ids
    }
  }
}

################################################################################
# TGW Peering
################################################################################

data "aws_caller_identity" "london" {
  provider = aws.london
}

module "tgw_peering" {
  source = "../../modules/tgw-peering"
  providers = {
    aws.requester = aws.london
    aws.accepter  = aws.paris
  }

  requestor_tgw_id = module.tgw_london.transit_gateway_id
  accepter_tgw_id  = module.tgw_paris.transit_gateway_id
  peer_region      = "eu-west-3"
  peer_account_id  = data.aws_caller_identity.london.account_id
}

################################################################################
# TGW Peering Associations
################################################################################

resource "aws_ec2_transit_gateway_route_table_association" "peering_london" {
  provider                       = aws.london
  transit_gateway_attachment_id  = module.tgw_peering.peering_attachment_id
  transit_gateway_route_table_id = module.tgw_london.transit_gateway_route_table_id

  depends_on = [module.tgw_peering]
}

resource "aws_ec2_transit_gateway_route_table_association" "peering_paris" {
  provider                       = aws.paris
  transit_gateway_attachment_id  = module.tgw_peering.peering_attachment_id
  transit_gateway_route_table_id = module.tgw_paris.transit_gateway_route_table_id

  depends_on = [module.tgw_peering]
}

################################################################################
# TGW Routes (Static)
################################################################################

# London TGW needs to route to Paris VPC CIDRs via Peering
resource "aws_ec2_transit_gateway_route" "london_to_paris_vpc2" {
  provider = aws.london
  destination_cidr_block         = "11.0.0.0/16"
  transit_gateway_attachment_id  = module.tgw_peering.peering_attachment_id
  transit_gateway_route_table_id = module.tgw_london.transit_gateway_route_table_id

  depends_on = [module.tgw_peering]
}

resource "aws_ec2_transit_gateway_route" "london_to_paris_vpc3" {
  provider = aws.london
  destination_cidr_block         = "12.0.0.0/16"
  transit_gateway_attachment_id  = module.tgw_peering.peering_attachment_id
  transit_gateway_route_table_id = module.tgw_london.transit_gateway_route_table_id

  depends_on = [module.tgw_peering]
}

# Paris TGW needs to route to London VPC CIDR via Peering
resource "aws_ec2_transit_gateway_route" "paris_to_london" {
  provider = aws.paris
  destination_cidr_block         = "10.0.0.0/16"
  transit_gateway_attachment_id  = module.tgw_peering.peering_attachment_id
  transit_gateway_route_table_id = module.tgw_paris.transit_gateway_route_table_id

  depends_on = [module.tgw_peering]
}

################################################################################
# VPC Routes (Pointing to TGW)
################################################################################

# London Private Subnet -> Paris
resource "aws_route" "london_private_to_paris2" {
  provider               = aws.london
  route_table_id         = module.vpc_london_1.private_route_table_id
  destination_cidr_block = "11.0.0.0/16"
  transit_gateway_id     = module.tgw_london.transit_gateway_id
}

resource "aws_route" "london_private_to_paris3" {
  provider               = aws.london
  route_table_id         = module.vpc_london_1.private_route_table_id
  destination_cidr_block = "12.0.0.0/16"
  transit_gateway_id     = module.tgw_london.transit_gateway_id
}

# London Public Subnet -> Paris
resource "aws_route" "london_public_to_paris2" {
  provider               = aws.london
  route_table_id         = module.vpc_london_1.public_route_table_id
  destination_cidr_block = "11.0.0.0/16"
  transit_gateway_id     = module.tgw_london.transit_gateway_id
}

resource "aws_route" "london_public_to_paris3" {
  provider               = aws.london
  route_table_id         = module.vpc_london_1.public_route_table_id
  destination_cidr_block = "12.0.0.0/16"
  transit_gateway_id     = module.tgw_london.transit_gateway_id
}

# Paris VPC 2 -> London
resource "aws_route" "paris2_to_london" {
  provider               = aws.paris
  route_table_id         = module.vpc_paris_2.private_route_table_id
  destination_cidr_block = "10.0.0.0/16"
  transit_gateway_id     = module.tgw_paris.transit_gateway_id
}
resource "aws_route" "paris2_to_paris3" {
  provider               = aws.paris
  route_table_id         = module.vpc_paris_2.private_route_table_id
  destination_cidr_block = "12.0.0.0/16"
  transit_gateway_id     = module.tgw_paris.transit_gateway_id
}


# Paris VPC 3 -> London
resource "aws_route" "paris3_to_london" {
  provider               = aws.paris
  route_table_id         = module.vpc_paris_3.private_route_table_id
  destination_cidr_block = "10.0.0.0/16"
  transit_gateway_id     = module.tgw_paris.transit_gateway_id
}

resource "aws_route" "paris3_to_paris2" {
  provider               = aws.paris
  route_table_id         = module.vpc_paris_3.private_route_table_id
  destination_cidr_block = "11.0.0.0/16"
  transit_gateway_id     = module.tgw_paris.transit_gateway_id
}

################################################################################
# EC2 Bastion (London)
################################################################################

################################################################################
# EC2 Bastion (London)
################################################################################

resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion" {
  provider   = aws.london
  key_name   = "bastion-key"
  public_key = tls_private_key.bastion.public_key_openssh
}

resource "local_file" "bastion_key" {
  content  = tls_private_key.bastion.private_key_pem
  filename = "${path.module}/bastion-key.pem"
  file_permission = "0400"
}

module "ec2_bastion" {
  source = "../../modules/ec2"
  providers = { aws = aws.london }

  name                   = "bastion-vpc-london-1"
  instance_type          = "t3.micro"
  subnet_id              = module.vpc_london_1.public_subnet_ids[0]
  vpc_security_group_ids = [module.sg_public_vpc1.security_group_id]
  key_name               = aws_key_pair.bastion.key_name

  # Provisioning
  enable_provisioning    = true
  provision_key_content  = tls_private_key.private_instances.private_key_pem
  connection_private_key = tls_private_key.bastion.private_key_pem
}

################################################################################
# Private EC2 Keys
################################################################################

resource "tls_private_key" "private_instances" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "london_private" {
  provider   = aws.london
  key_name   = "london-private-key"
  public_key = tls_private_key.private_instances.public_key_openssh
}

resource "aws_key_pair" "paris_private" {
  provider   = aws.paris
  key_name   = "paris-private-key"
  public_key = tls_private_key.private_instances.public_key_openssh
}

resource "local_file" "private_instances_key" {
  content  = tls_private_key.private_instances.private_key_pem
  filename = "${path.module}/private-instances-key.pem"
  file_permission = "0400"
}

################################################################################
# EC2 Private Instances
################################################################################

module "ec2_london_private" {
  source = "../../modules/ec2"
  providers = { aws = aws.london }

  name                   = "private-vpc-london-1"
  instance_type          = "t3.micro"
  subnet_id              = module.vpc_london_1.private_subnet_ids[0]
  vpc_security_group_ids = [module.sg_private_vpc1.security_group_id]
  key_name               = aws_key_pair.london_private.key_name

  # Provisioning via Bastion
  enable_provisioning    = true
  provision_key_content  = tls_private_key.private_instances.private_key_pem
  connection_private_key = tls_private_key.private_instances.private_key_pem
  bastion_host           = module.ec2_bastion.public_ip
  bastion_private_key    = tls_private_key.bastion.private_key_pem

  depends_on = [module.ec2_bastion]
}

module "ec2_paris_2" {
  source = "../../modules/ec2"
  providers = { aws = aws.paris }

  name                   = "private-vpc-paris-2"
  instance_type          = "t3.micro"
  subnet_id              = module.vpc_paris_2.private_subnet_ids[0]
  vpc_security_group_ids = [module.sg_vpc_paris_2.security_group_id]
  key_name               = aws_key_pair.paris_private.key_name

  # Provisioning via Bastion
  enable_provisioning    = true
  provision_key_content  = tls_private_key.private_instances.private_key_pem
  connection_private_key = tls_private_key.private_instances.private_key_pem
  bastion_host           = module.ec2_bastion.public_ip
  bastion_private_key    = tls_private_key.bastion.private_key_pem

  depends_on = [module.ec2_bastion]
}

module "ec2_paris_3" {
  source = "../../modules/ec2"
  providers = { aws = aws.paris }

  name                   = "private-vpc-paris-3"
  instance_type          = "t3.micro"
  subnet_id              = module.vpc_paris_3.private_subnet_ids[0]
  vpc_security_group_ids = [module.sg_vpc_paris_3.security_group_id]
  key_name               = aws_key_pair.paris_private.key_name

  # Provisioning via Bastion
  enable_provisioning    = true
  provision_key_content  = tls_private_key.private_instances.private_key_pem
  connection_private_key = tls_private_key.private_instances.private_key_pem
  bastion_host           = module.ec2_bastion.public_ip
  bastion_private_key    = tls_private_key.bastion.private_key_pem

  depends_on = [module.ec2_bastion]
}







