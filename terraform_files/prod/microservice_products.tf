resource "aws_security_group" "products_sg" {
  name        = var.products_sg_name
  description = "Security group for products service"

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

resource "aws_ecs_task_definition" "products" {
  family                   = var.product_family_ecs_task_definition
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role

  cpu    = var.product_cpu
  memory = var.product_memory

  container_definitions = jsonencode([
    {
      name          = var.product_container_name
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

resource "aws_ecs_service" "products" {
  name            = var.ecs_product_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.products.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.networks_ids
    security_groups = [aws_security_group.products_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.products.arn
    container_name   = var.product_container_name
    container_port   = 8080
  }
}

resource "aws_lb" "products" {
  name               = var.products_alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = var.networks_ids
  security_groups    = [aws_security_group.load_balancers.id]
  tags = {
    Name = "products-alb"
  }
}

resource "aws_lb_listener" "products" {
  load_balancer_arn = aws_lb.products.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.products.arn
  }
}

resource "aws_lb_target_group" "products" {
  name     = var.products_target_group_lb_name
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

output "products_service_url" {
  value = aws_lb.products.dns_name
}
