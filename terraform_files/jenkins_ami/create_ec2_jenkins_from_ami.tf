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
    vpc_id = "vpc-0af16c272bcefd646"

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
    ami           = "ami-0280bfe57119fae0d"
    instance_type = "t2.medium"
    subnet_id = "subnet-028012d4808e800ff"
    key_name = "proyecto-devops"

    vpc_security_group_ids = [
      aws_security_group.jenkins-sg.id
    ]

    root_block_device {
      delete_on_termination = false
      volume_size = 20
      volume_type = "gp2"
    }

    depends_on = [ aws_security_group.jenkins-sg ]
  }

  output "ec2instance" {
    value = aws_instance.jenkins_server.public_ip
  }
