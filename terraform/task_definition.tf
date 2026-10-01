resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/ecs-fargate-demo"
  retention_in_days = 7

  tags = {
    Name    = "ecs-fargate-demo-logs"
    Project = "ecs-fargate-devops"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "ecs-fargate-demo"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "ecs-fargate-demo"
      image     = "${aws_ecr_repository.ecs_fargate_demo.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name    = "ecs-fargate-demo-task"
    Project = "ecs-fargate-devops"
  }
}
