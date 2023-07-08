# Configuración del proveedor de AWS
provider "aws" {
  region = "us-east-1" 
}


# Creación del grupo de seguridad
resource "aws_security_group" "products_sg" {
  name        = "products-sg"
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

# Creación de la definición de la tarea de ECS
resource "aws_ecs_task_definition" "products" {
  family                   = "products"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = "arn:aws:iam::187585600197:role/LabRole"

  cpu    = "256"  # Asigna la cantidad de CPU en milicore
  memory = "512"  # Asigna la cantidad de memoria en MiB

  container_definitions = jsonencode([
    {
      name          = "products"
      image         = "187585600197.dkr.ecr.us-east-1.amazonaws.com/products-service:test-4"
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

# Creación del cluster de ECS
resource "aws_ecs_cluster" "production" {
  name = "production"
}

# Creación del servicio de ECS
resource "aws_ecs_service" "products" {
  name            = "products"
  cluster         = aws_ecs_cluster.production.id
  task_definition = aws_ecs_task_definition.products.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-036d2b225819bfb0a", "subnet-07dc0f066f2de4675"]
    security_groups = [aws_security_group.products_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.products.arn
    container_name   = "products"
    container_port   = 8080
  }
}

# Creación del ALB (Application Load Balancer)
resource "aws_lb" "products" {
  name               = "products-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-036d2b225819bfb0a", "subnet-07dc0f066f2de4675"] # Reemplaza con los IDs de las subredes existentes de tu VPC

  tags = {
    Name = "products-alb"
  }
}

# Creación del listener del ALB
resource "aws_lb_listener" "products" {
  load_balancer_arn = aws_lb.products.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.products.arn
  }
}

# Creación del grupo de destino del ALB
resource "aws_lb_target_group" "products" {
  name     = "products-target-group"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = "vpc-0d93e90e894b1a396"  

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



# Salida con la URL del servicio
output "products_service_url" {
  value = aws_lb.products.dns_name
}