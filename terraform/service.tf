resource "aws_ecs_service" "app" {
  name            = "ecs-fargate-demo-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn

  desired_count = 2
  launch_type   = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.public_a.id,
      aws_subnet.public_b.id
    ]

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "ecs-fargate-demo"
    container_port   = 8000
  }

  depends_on = [
    aws_lb_listener.http
  ]

  tags = {
    Name    = "ecs-fargate-demo-service"
    Project = "ecs-fargate-devops"
  }
}
