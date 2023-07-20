resource "aws_security_group" "shipping_sg" {
  name        = var.shipping_sg_name
  description = "Security group for shipping service"

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

resource "aws_ecs_task_definition" "shipping" {
  family                   = var.shipping_family_ecs_task_definition
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role

  cpu    = var.shipping_cpu
  memory = var.shipping_memory

  container_definitions = jsonencode([
    {
      name          = var.shipping_container_name
      image         = "docker.io/gazgeek/springboot-helloworld:latest"
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

resource "aws_ecs_service" "shipping" {
  name            = var.ecs_shipping_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.shipping.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.networks_ids
    security_groups = [aws_security_group.shipping_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.shipping.arn
    container_name   = var.shipping_container_name
    container_port   = 8080
  }
}

resource "aws_lb" "shipping" {
  name               = var.shipping_alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = var.networks_ids
  security_groups    = [aws_security_group.load_balancers.id]
  tags = {
    Name = "shipping-alb"
  }
}

resource "aws_lb_listener" "shipping" {
  load_balancer_arn = aws_lb.shipping.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.shipping.arn
  }
}

resource "aws_lb_target_group" "shipping" {
  name     = var.shipping_target_group_lb_name
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

output "shipping_service_url" {
  value = aws_lb.shipping.dns_name
}
