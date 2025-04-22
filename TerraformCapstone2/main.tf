# Configure AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group allowing ALL traffic + explicit SSH
resource "aws_security_group" "allow_all" {
  name        = "allow_all_traffic"
  description = "Allow ALL inbound and outbound traffic"

  # Allow ALL inbound traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Explicit SSH rule (redundant but clear)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Allow ALL outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-all-traffic"
  }
}

# Jenkins Server
resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"  # Changed to t2.medium
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = "new2"  # Your existing key pair
  
  tags = {
    Name = "JenkinsServer"
    Role = "CI/CD"
  }
}

# Test Server  
resource "aws_instance" "test_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"  # Changed to t2.medium
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = "new2"
  
  tags = {
    Name = "TestServer"
    Role = "Testing"
  }
}

# Production Server
resource "aws_instance" "prod_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"  # Changed to t2.medium
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = "new2"
  
  tags = {
    Name = "ProdServer"
    Role = "Production"
  }
}

# Output IPs
output "jenkins_ip" {
  value = aws_instance.jenkins_server.public_ip
}

output "test_ip" {
  value = aws_instance.test_server.public_ip
}

output "prod_ip" {
  value = aws_instance.prod_server.public_ip
}
