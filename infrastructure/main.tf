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

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "main-vpc" }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "main-igw" }
}

# Subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-central-1a"

  tags = { Name = "public-subnet" }
}

##Private
  # Private Subnets
  resource "aws_subnet" "private_subnet_1" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "eu-central-1b"
    tags = {
      Name = "Private Subnet-1"
    }
  }
  ##Private
  resource "aws_subnet" "private_subnet_2" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "eu-central-1c"
    tags = {
      Name = "Private Subnet-2"
    }
  }
# COMBINE PRIVATE SUBNETS
  resource "aws_db_subnet_group" "rds_subnet_group" {
    name       = "my-db-subnet-group"
    subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id ]  #if multi AZ add another subnet
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


# EC2 Instance
resource "aws_instance" "app_server" {
 ami = "ami-08697da0e8d9f59ec"  # Amazon Linux 2023 in eu-central-1
 instance_type = "t2.micro"
 vpc_security_group_ids = [aws_security_group.app_sg.id] 
 subnet_id = aws_subnet.public.id
 tags = {
  Name = "app-server"
 }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "joy-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id

  # PostgreSQL access only from EC2
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.app_sg.id]
    description = "PostgreSQL access from EC2"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# DB Instance
resource "aws_db_instance" "app_db" {
 allocated_storage = 20
 engine = "postgres"
 engine_version = "17.6"
 instance_class = "db.t3.micro"
 db_name = "grocerymate_db"
 username = "postgres"
 password = "Tabejoy01"
 #public_accessible = false
 skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
}


# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "public-route-table" }
}

# Route to Internet
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate with subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

