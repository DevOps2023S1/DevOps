resource "aws_s3_bucket" "fronts-bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_tag_name
    Environment = var.bucket_tag_environment
  }
}

#################################################################################################

############### Creación del cluster de ECS.
############### Este cluster tendra todos los servicios de produccion

resource "aws_ecs_cluster" "production" {
  name = var.cluster_name
}

############# Creación del grupo de seguridad
resource "aws_security_group" "load_balancers" {
  name        = var.load_balancer_name
  description = "Security group for products service"

  ingress {
    from_port   = 80
    to_port     = 80
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

########################################################
################ microservicio PRODUCTS ################
########################################################

# Creación del grupo de seguridad
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

# Creación de la definición de la tarea de ECS
resource "aws_ecs_task_definition" "products" {
  family                   = var.product_family_ecs_task_definition
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = "arn:aws:iam::187585600197:role/LabRole"

  cpu    = var.product_cpu
  memory = var.product_memory

  container_definitions = jsonencode([
    {
      name          = var.product_container_name
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

# Creación del servicio de ECS
resource "aws_ecs_service" "products" {
  name            = var.ecs_product_name
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
    container_name   = var.product_container_name
    container_port   = 8080
  }
}

# Creación del ALB (Application Load Balancer)
resource "aws_lb" "products" {
  name               = var.products_alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-036d2b225819bfb0a", "subnet-07dc0f066f2de4675"]
  security_groups    = [aws_security_group.load_balancers.id]
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
  name     = var.products_target_group_lb_name 
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


########################################################
################ microservicio ORDERS ################
########################################################

# Creación del grupo de seguridad
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

# Creación de la definición de la tarea de ECS
resource "aws_ecs_task_definition" "orders" {
  family                   = var.order_family_ecs_task_definition
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = "arn:aws:iam::187585600197:role/LabRole"

  cpu    = var.order_cpu  # Asigna la cantidad de CPU en milicore
  memory = var.order_memory  # Asigna la cantidad de memoria en MiB

  container_definitions = jsonencode([
    {
      name          = var.order_container_name
      image         = "187585600197.dkr.ecr.us-east-1.amazonaws.com/orders-service:test-8" 
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

# Creación del servicio de ECS
resource "aws_ecs_service" "orders" {
  name            = var.ecs_order_name
  cluster         = aws_ecs_cluster.production.id
  task_definition = aws_ecs_task_definition.orders.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-036d2b225819bfb0a", "subnet-07dc0f066f2de4675"]
    security_groups = [aws_security_group.orders_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.orders.arn
    container_name   = var.order_container_name
    container_port   = 8080
  }
}

# Creación del ALB (Application Load Balancer)
resource "aws_lb" "orders" {
  name               = var.orders_alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-036d2b225819bfb0a", "subnet-07dc0f066f2de4675"] # Reemplaza con los IDs de las subredes existentes de tu VPC
  security_groups    = [aws_security_group.load_balancers.id]
  tags = {
    Name = "orders-alb"
  }
}

# Creación del listener del ALB
resource "aws_lb_listener" "orders" {
  load_balancer_arn = aws_lb.orders.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.orders.arn
  }
}

# Creación del grupo de destino del ALB
resource "aws_lb_target_group" "orders" {
  name     = var.orders_target_group_lb_name
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
output "orders_service_url" {
  value = aws_lb.orders.dns_name
}


########################################################
################ microservicio SHIPPING ################
########################################################

# Creación del grupo de seguridad
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

# Creación de la definición de la tarea de ECS
resource "aws_ecs_task_definition" "shipping" {
  family                   = var.shipping_family_ecs_task_definition
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = "arn:aws:iam::187585600197:role/LabRole"

  cpu    = var.shipping_cpu
  memory = var.shipping_memory 

  container_definitions = jsonencode([
    {
      name          = var.shipping_container_name
      image         = "187585600197.dkr.ecr.us-east-1.amazonaws.com/shipping-service:test-2"
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

# Creación del servicio de ECS
resource "aws_ecs_service" "shipping" {
  name            = var.ecs_shipping_name
  cluster         = aws_ecs_cluster.production.id
  task_definition = aws_ecs_task_definition.shipping.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-036d2b225819bfb0a", "subnet-07dc0f066f2de4675"]
    security_groups = [aws_security_group.shipping_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.shipping.arn
    container_name   = var.shipping_container_name
    container_port   = 8080
  }
}

# Creación del ALB (Application Load Balancer)
resource "aws_lb" "shipping" {
  name               = var.shipping_alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-036d2b225819bfb0a", "subnet-07dc0f066f2de4675"]
  security_groups    = [aws_security_group.load_balancers.id]
  tags = {
    Name = "shipping-alb"
  }
}

# Creación del listener del ALB
resource "aws_lb_listener" "shipping" {
  load_balancer_arn = aws_lb.shipping.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.shipping.arn
  }
}

# Creación del grupo de destino del ALB
resource "aws_lb_target_group" "shipping" {
  name     = var.shipping_target_group_lb_name
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
output "shipping_service_url" {
  value = aws_lb.shipping.dns_name
}


########################################################
################ microservicio PAYMENTS ################
########################################################

# Creación del grupo de seguridad
resource "aws_security_group" "payments_sg" {
  name        = var.payment_sg_name
  description = "Security group for payments service"

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
resource "aws_ecs_task_definition" "payments" {
  family                   = var.payment_family_ecs_task_definition
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = "arn:aws:iam::187585600197:role/LabRole"

  cpu    = var.payment_cpu 
  memory = var.payment_memory 

  container_definitions = jsonencode([
    {
      name          = var.payment_container_name
      image         = "187585600197.dkr.ecr.us-east-1.amazonaws.com/payments-service:test-1"
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

# Creación del servicio de ECS
resource "aws_ecs_service" "payments" {
  name            = var.ecs_payments_name
  cluster         = aws_ecs_cluster.production.id
  task_definition = aws_ecs_task_definition.payments.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-036d2b225819bfb0a", "subnet-07dc0f066f2de4675"]
    security_groups = [aws_security_group.payments_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.payments.arn
    container_name   = var.payment_container_name
    container_port   = 8080
  }
}

# Creación del ALB (Application Load Balancer)
resource "aws_lb" "payments" {
  name               = var.payment_alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-036d2b225819bfb0a", "subnet-07dc0f066f2de4675"]
  security_groups    = [aws_security_group.load_balancers.id]
  tags = {
    Name = "payments-alb"
  }
}

# Creación del listener del ALB
resource "aws_lb_listener" "payments" {
  load_balancer_arn = aws_lb.payments.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.payments.arn
  }
}

# Creación del grupo de destino del ALB
resource "aws_lb_target_group" "payments" {
  name     = var.payment_target_group_lb_name
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
output "payments_service_url" {
  value = aws_lb.payments.dns_name
}