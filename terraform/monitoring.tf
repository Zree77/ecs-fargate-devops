resource "aws_sns_topic" "alerts" {
  name = "ecs-fargate-alerts"

  tags = {
    Name    = "ecs-fargate-alerts"
    Project = "ecs-fargate-devops"
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "zreeprojects@gmail.com"
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "ecs-fargate-high-cpu"
  alarm_description   = "Triggers when ECS Fargate service CPU utilization is high"
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2
  metric_name        = "CPUUtilization"
  namespace          = "AWS/ECS"
  period             = 60
  statistic          = "Average"

  threshold = 70

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  treat_missing_data = "notBreaching"

  tags = {
    Name    = "ecs-fargate-high-cpu"
    Project = "ecs-fargate-devops"
  }
}
