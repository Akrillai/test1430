terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.38.0"
    }
  }
}


resource "aws_security_group" "allow_app_traffic" {
  name        = "easy_access_cert"
  ingress {
    description = "app from anywhere"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_instance" "builder_instance" {
  ami                        = "ami-04842bc62789b682e"
  instance_type              = "t2.small"
  key_name                   = "AWS_EC2s"
  vpc_security_group_ids     = ["${aws_security_group.allow_app_traffic.id}"]

  tags = {
    Name = "devops-cert_task-builder"
  }

}

resource "aws_instance" "webserver_instance" {
  ami                        = "ami-04842bc62789b682e"
  instance_type              = "t2.small"
  key_name                   = "AWS_EC2s"
  vpc_security_group_ids     = ["${aws_security_group.allow_app_traffic.id}"]


  tags = {
    Name = "devops-cert_task-webserver"
  }

}
