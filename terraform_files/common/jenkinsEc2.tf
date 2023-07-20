  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
      }
    }
  }

  provider "aws" {
    profile = "default"
    region  = "us-east-1"
  }

  resource "aws_security_group" "jenkins-sg" {
    name = "jenkins"
    description = "SG for jenkins server"
    vpc_id = "vpc-0d93e90e894b1a396"

    ingress {
      from_port = 22
      protocol = "tcp"
      to_port = 22
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 8080
      protocol = "tcp"
      to_port = 8080
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
    }

    lifecycle {
      create_before_destroy = true
    }
  }

  resource "aws_instance" "jenkins_server" {
    ami           = "ami-0889a44b331db0194"
    instance_type = "t3a.medium"
    subnet_id = "subnet-036d2b225819bfb0a"
    key_name = "proyecto-devops"

    vpc_security_group_ids = [
      aws_security_group.jenkins-sg.id
    ]

    root_block_device {
      delete_on_termination = false
      volume_size = 20
      volume_type = "gp2"
    }

    user_data = <<-EOF
    #!/bin/bash
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    sudo yum upgrade -y
    sudo dnf install java-11-amazon-corretto -y
    sudo yum install docker -y
    sudo yum install jenkins -y
    sudo usermod -aG docker jenkins
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    sudo systemctl enable docker
    sudo systemctl start docker
    EOF

    depends_on = [ aws_security_group.jenkins-sg ]
  }

  output "ec2instance" {
    value = aws_instance.jenkins_server.public_ip
  }