
resource "aws_instance" "docker" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  count                  = var.ec2_count
  subnet_id              = aws_subnet.main-public-1.id
  key_name               = aws_key_pair.mykeypair.key_name
  vpc_security_group_ids = [aws_security_group.myinstance.id]

  # provisioner "local-exec" {
  # command = "echo ${aws_instance.docker.public_ip} > mytext"
  #  }

  tags = {
    Name = "docker"
  }
}

