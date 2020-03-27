data aws_region lookup {}

resource aws_cloudwatch_log_group cloud_logs {
  name_prefix = var.cloud_logs
  retention_in_days = 1
}

resource aws_ecs_task_definition ecs_task {
  family = var.image_name
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.exec_role.arn
  task_role_arn = aws_iam_role.s3_role.arn
  cpu = "256"
  memory = "512"
  container_definitions = jsonencode([
    {
      name: var.image_name,
      image: var.image_id,
      cpu: 200,
      memory: 400,
      portMappings: [
        {
          hostPort: var.port,
          containerPort: var.port,
          protocol: "tcp"
        }
      ],
      logConfiguration: {
        logDriver: "awslogs",
        options: {
          awslogs-region: data.aws_region.lookup.name,
          awslogs-group: aws_cloudwatch_log_group.cloud_logs.name,
          awslogs-stream-prefix: var.cloud_logs_stream
        }
      }
    }
  ])
}

resource aws_ecs_service chartmuseum_svc {
 name = var.svc_name
 cluster = var.cluster_id
 network_configuration {
   subnets = "${[aws_subnet.svc-private.id,aws_subnet.svc-private-2.id]}"
   security_groups = "${[aws_security_group.sg-1.id]}"
   assign_public_ip = true
 }
 launch_type = "FARGATE"
 task_definition = aws_ecs_task_definition.ecs_task.arn

 desired_count = 1
  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"
    container_name   = "chartmuseum"
    container_port   = 8080
  }
  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 0
}
