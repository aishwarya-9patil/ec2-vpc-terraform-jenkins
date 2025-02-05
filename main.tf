provider "aws" {
  region = "ap-south-1"
}

// Create VPC
resource "aws_vpc" "aisuu_vpc" {
  cidr_block                     = "10.0.0.0/16"
  instance_tenancy                = "default"
  enable_dns_hostnames            = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "terraformVpc"
  }
}

// Create Internet Gateway (IGW)
resource "aws_internet_gateway" "aishu_igw" {
  vpc_id = aws_vpc.aisuu_vpc.id

  tags = {
    Name = "terraformigw"
  }
}

// Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                   = aws_vpc.aisuu_vpc.id
  cidr_block               = "10.0.1.0/24"
  availability_zone        = "ap-south-1a"
  map_public_ip_on_launch  = true

  tags = {
    Name = "terraform_public_subnet"
  }
}

// Create Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.aisuu_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aishu_igw.id
  }

  tags = {
    Name = "publicRT"
  }
}

// Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

// Create Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                   = aws_vpc.aisuu_vpc.id
  cidr_block               = "10.0.2.0/24"
  availability_zone        = "ap-south-1a"
  map_public_ip_on_launch  = false

  tags = {
    Name = "terraform_private_subnet"
  }
}

// Create Security Group
resource "aws_security_group" "TF_SG" {
  name        = "terraform_SG"
  description = "Allow SSH, HTTP, and HTTPS traffic"
  vpc_id      = aws_vpc.aisuu_vpc.id

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change this for better security (e.g., your IP)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TF_SG"
  }
}

// Create an EC2 Instance
resource "aws_instance" "my_instance" {
  ami                    = "ami-05fa46471b02db0ce"  # Update to your desired AMI
  instance_type          = "t2.medium"                # Change this to your desired instance type
  key_name               = "aish-key"                 # Ensure you create or use an existing key pair

  subnet_id             = aws_subnet.public_subnet.id   # Reference the public subnet
  vpc_security_group_ids = [aws_security_group.TF_SG.id]  # Use the security group ID

  tags = {
    Name = "terraform-server"
  }
}

// Output the public IP of the instance
output "instance_ip" {
  value = aws_instance.my_instance.public_ip
}
