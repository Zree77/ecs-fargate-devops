resource "aws_ecs_cluster" "main" {
  name = "ecs-fargate-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name    = "ecs-fargate-cluster"
    Project = "ecs-fargate-devops"
  }
}
