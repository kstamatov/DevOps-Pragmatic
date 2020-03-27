data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "test_instance" {
  ami = data.aws_ami.ubuntu.id
  key_name = var.KEY_NAME
  instance_type = "t2.micro"
#  vpc_security_group_ids = [aws_security_group.sg-1.id]
  associate_public_ip_address = true
  tags = {
    Name = "DEVOPS_TESTING"
  }
}
