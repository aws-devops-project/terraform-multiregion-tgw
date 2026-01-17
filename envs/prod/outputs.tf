output "london_bastion_ip" {
  value = module.ec2_bastion.public_ip
}

output "tgw_london_id" {
  value = module.tgw_london.transit_gateway_id
}

output "tgw_paris_id" {
  value = module.tgw_paris.transit_gateway_id
}

output "london_private_ips" {
  value = {
    bastion        = module.ec2_bastion.private_ip
    london_private = module.ec2_london_private.private_ip
  }
}

output "paris_private_ips" {
  value = {
    paris_2 = module.ec2_paris_2.private_ip
    paris_3 = module.ec2_paris_3.private_ip
  }
}
