resource "aws_security_group" "orders_sg" {
  name        = var.order_sg_name
  description = "Security group for orders service"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "orders" {
  family                   = var.order_family_ecs_task_definition
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role

  cpu    = var.order_cpu
  memory = var.order_memory

  container_definitions = jsonencode([
    {
      name          = var.order_container_name  
      image         = "docker.io/gazgeek/springboot-helloworld:latest"
      environment   = [
        { "name": "APP_ARGS", "value": "http://${aws_lb.payments.dns_name} http://${aws_lb.shipping.dns_name} http://${aws_lb.products.dns_name}" }
      ]
      portMappings = [
        {
          containerPort = 8080,
          hostPort      = 8080,
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "orders" {
  name            = var.ecs_order_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.orders.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.networks_ids
    security_groups = [aws_security_group.orders_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.orders.arn
    container_name   = var.order_container_name
    container_port   = 8080
  }
}

resource "aws_lb" "orders" {
  name               = var.orders_alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = var.networks_ids
  security_groups    = [aws_security_group.load_balancers.id]
  tags = {
    Name = "orders-alb"
  }
}

resource "aws_lb_listener" "orders" {
  load_balancer_arn = aws_lb.orders.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.orders.arn
  }
}

resource "aws_lb_target_group" "orders" {
  name     = var.orders_target_group_lb_name
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "404"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

output "orders_service_url" {
  value = aws_lb.orders.dns_name
}
