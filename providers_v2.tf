variable "cidr_blocks" { 
 description = "cidr blocks and name tags for vpc and subnets"
 type = list(object({ #change array type from string array to object array
	cidr_block = string #string in this object/array needs to be a string 
	name = string #string in this object/array needs to be a string	  
 })) 
}
provider "aws" {
 region = "us-east-1"
}
resource "aws_vpc" "development-vpc" {
 cidr_block = var.cidr_blocks[0].cidr_block #reference the object attribute "cidr_block" of this array via .cidr_block
 tags = {
  Name: var.cidr_blocks[0].name #reference the object attribute "name" of this array via .name
 }
}
resource "aws_subnet" "dev-subnet-1" {
 vpc_id = aws_vpc.development-vpc.id
 cidr_block = var.cidr_blocks[1].cidr_block #reference the object attribute "cidr_block" of this array via .cidr_block
 availability_zone = "us-east-1a"
 tags = {
  Name: var.cidr_blocks[1].name #reference the object attribute "name" of this array via .name
  }
}






