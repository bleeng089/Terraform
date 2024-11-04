provider "aws" {
  region = "us-east-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
resource "aws_vpc" "myapp-vpc" {
 cidr_block = var.vpc_cidr_block
 tags = {
  Name: "${var.env_prefix}-vpc" 
 }
}
resource "aws_subnet" "myapp-subnet-1" {
 vpc_id = aws_vpc.myapp-vpc.id
 cidr_block = var.subnet_cidr_block 
 availability_zone = var.avail_zone
 tags = {
  Name: "${var.env_prefix}-vpc" 
  }
}
resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-rtb"
  }
}
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
}
resource "aws_route_table_association" "myapp-subnet-1_to_rtb" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
}


resource "aws_security_group" "myapp-sg" {
	name = "myapp-sg"
	vpc_id = aws_vpc.myapp-vpc.id
ingress {
	from_port =22 
	to_port = 22
	protocol = "TCP"
	cidr_blocks = ["0.0.0.0/0"]
}
ingress {
	from_port = 8080 
	to_port = 8080 
	protocol = "TCP" 
	cidr_blocks = ["0.0.0.0/0"]
	}
egress {
	from_port = 0 #any port
	to_port = 0 
	protocol = "-1" #all protocols
	cidr_blocks = ["0.0.0.0/0"]
	prefix_list_ids = [] #allows egress to vpc endpoints
	}
tags = {
	Name: "${var.env_prefix}-sg"
	}
}




data "aws_ami" "latest-amazon-linux-image" { 
	most_recent = true 
	owners = ["amazon"] 
	filter { 
		name = "name" 
		values = ["amzn2-ami-kernel-*-x86_64-gp2"] 
	}
	filter {
		name = "virtualization-type" 
		values = ["hvm"]
	}	
}

variable "instance_type" {}
resource "aws_instance" "myapp-server" {
	ami = data.aws_ami.latest-amazon-linux-image.id
	instance_type = var.instance_type

	subnet_id = aws_subnet.myapp-subnet-1.id 
	vpc_security_group_ids = [aws_security_group.myapp-sg.id] 
	availability_zone = var.avail_zone 

	associate_public_ip_address = true 
	key_name = aws_key_pair.ssh-key.key_name

	user_data = file("entry-script.sh")

user_data_replace_on_change = true
	tags = {
		Name: "${var.env_prefix}-server"
	}
}

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}
output "ec2-public_ip" {
	value = aws_instance.myapp-server.public_ip
}
output "ec2-public_dns" {
	value = aws_instance.myapp-server.public_dns
}

resource "aws_key_pair" "ssh-key" {
	key_name = "server-key"
	public_key = file(var.public_key_location) 
}
variable "public_key_location" {}