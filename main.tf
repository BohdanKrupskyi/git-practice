variable "aws_access_key" {}
variable "aws_secret_key" {}
# Configure the AWS Provider
provider "aws" {
  region     = "eu-west-3"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

}

# Security Group
resource "aws_security_group" "My-First-SecurityGroup" {
  name_prefix = "terraform-security-group-"

  # Inbound Rules
  ingress {
    description = "Allow SSH from Home IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["15.188.11.150/32"] # Replace YOUR_HOME_IP with your actual IP address
  }

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

  # Outbound Rules
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key Pair (SSH Key)
resource "aws_key_pair" "My-First-KeyPair" {
  key_name   = "my-terraform-key"
  public_key = file("C:/Users/bkrup/Pablo2.pub") # Replace with the path to your public SSH key
}

# EC2 Instance
resource "aws_instance" "My-First-Teraserver" {
  ami           = "ami-06e02ae7bdac6b938"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.My-First-KeyPair.key_name
  security_groups = [aws_security_group.My-First-SecurityGroup.name]

  tags = {
    Name = "HelloWorld"
  }

  user_data = <<-EOT
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  EOT
}


