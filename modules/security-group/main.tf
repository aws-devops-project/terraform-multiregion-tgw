resource "aws_security_group" "this" {
    name = var.Name
    description = var.description
    vpc_id = var.vpc_id

    dynamic "ingress" {
        for_each = var.ingress_rules
        content {
            from_port = ingress.value.from_port
            to_port   = ingress.value.to_port
            protocol  = ingress.value.protocol
            cidr_blocks = ingress.value.cidr_blocks
            description = ingress.value.description != null ? ingress.value.description : null
        }      
    }
    dynamic "egress" {
        for_each = var.egress_rules
        content {
            from_port = egress.value.from_port
            to_port = egress.value.to_port
            cidr_blocks = egress.value.cidr_blocks
            protocol = egress.value.protocol
        } 
    }
    tags = {
        Name = var.Name
    }
  
}