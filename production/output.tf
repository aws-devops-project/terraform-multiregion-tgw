output "vpc_london_id" {
  value = {
    vpc_london_1 = module.vpc_london_1.vpc_id
  }
}

output "vpc_london_cidr" {
  value = {
    vpc_london_1 = module.vpc_london_1.vpc_cidr
  }
}

output "vpc_london_subnets" {
  value = {
    vpc_london_1_public_subnets = module.vpc_london_1.public_subnets_ids
  }
}
output "igw_london_id" {
  value = {
    vpc_london_1_igw_id = module.vpc_london_1.internet_gateway_id
  }

}

output "london_private_ip" {
  value = { 
    bastion_private_IP = module.ec2_bastion.private_ip
    ec2_vpc_london_2_private_IPs = module.ec2_london_private.private_ip
   }

}

output "london_public_ip" {
  value = { bastion_Public_IP = module.ec2_bastion.public_ip }

}
output "vpc_paris_id" {
  value = {
    paris_vpc_1 = module.vpc_paris_1.vpc_id
  }
} 
output "paris_private_ip" {
  value = { 
    ec2_vpc_paris_1_private_IPs = module.ec2_private_paris.private_ip
   }
} 