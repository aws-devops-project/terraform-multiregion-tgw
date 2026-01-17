data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*x86_64*"]
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  key_name      = var.key_name != "" ? var.key_name : null

  tags = {
    Name = var.name
  }
}

resource "null_resource" "provisioner" {
  count = var.enable_provisioning ? 1 : 0

  depends_on = [aws_instance.this]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.connection_private_key
    host        = var.bastion_host != "" ? aws_instance.this.private_ip : (aws_instance.this.public_ip != "" ? aws_instance.this.public_ip : aws_instance.this.private_ip)
    
    bastion_host        = var.bastion_host != "" ? var.bastion_host : null
    bastion_user        = var.bastion_host != "" ? var.bastion_user : null
    bastion_private_key = var.bastion_host != "" ? var.bastion_private_key : null
  }

  provisioner "remote-exec" {
    inline = [
      "rm -f ${var.provision_key_path}",
      "cat <<'EOF' > ${var.provision_key_path}\n${var.provision_key_content}\nEOF",
      "chmod 400 ${var.provision_key_path}"
    ]
  }
}

