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

resource "aws_ebs_snapshot" "ebs_snapshot" {
  volume_id = "vol-0c337de2d3658d73c"
}

resource "aws_ami" "ami_jenkins" {
  name                = "jenkins-ami"
  root_device_name    = "/dev/xvda"
  virtualization_type = "hvm"
  ebs_block_device {
    device_name = "/dev/xvda"
    snapshot_id = aws_ebs_snapshot.ebs_snapshot.id
    volume_size = 20
  }
}

resource "aws_ami_launch_permission" "jenkins_ami_public" {
  image_id = aws_ami.ami_jenkins.id
  group    = "all"
}
