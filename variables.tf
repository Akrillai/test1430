# variables.tf

variable "keyName" {
   default = "aws-ec2-key.pub"
}

variable "region" {
   default = "eu-west-2"
}

variable "instanceType" {
   default = "t2.micro"
}

# Ubuntu 22.04
variable "ami" {
   default = "ami-04842bc62789b682e"
}

variable "securityGroupDefault" {
   default = "devops-cert_task-default-sg"
}

variable "securityGroupWeb" {
   default = "devops-cert_task-web-sg"
}

#####################
# builder vars
variable "instanceNameBuilder" {
   default = "devops-cert_task-builder"
}

#####################
# webserver vars
variable "instanceNameWebserver" {
   default = "devops-cert_task-webserver"
}

# end of variables.tf
