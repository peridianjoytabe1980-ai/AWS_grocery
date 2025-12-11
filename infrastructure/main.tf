terraform {
 required_providers {
  aws = {
   source = "hashicorp/aws"
   version = "~> 5.0"
  }
 }
}

provider "aws" { 
 region = "eu-central-1"
}
resource "aws_security_group" "app_sg"{
 name = "app-sg" 
 description = "Allow SSH and app traffic"

 ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
  from_port = 80
  to_port = 80 
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }

 egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }
}
 
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]
  

filter {
 name = "name"
 values = ["amzn2-ami-hvm-*-x86_64-gp2"]
 } 
}

resource "aws_instance" "app_server" {
 ami = data.aws_ami.amazon_linux.id
 instance_type = "t2.micro"
 vpc_security_group_ids = [aws_security_group.app_sg.id] 

 tags = {
  Name = "app-server"
 }
}

resource "aws_db_instance" "app_db" {
 allocated_storage = 20
 engine = "postgres"
 engine_version = "17.6"
 instance_class = "db.t3.micro"
 db_name = "grocerymate_db"
 username = "postgres"
 password = "Tabejoy01"

 skip_final_snapshot = true
}

