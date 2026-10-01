terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_ecr_repository" "ecs_fargate_demo" {
  name                 = "ecs-fargate-demo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = "ecs-fargate-devops"
  }
}
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.ecs_fargate_demo.repository_url
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.app.dns_name
}
