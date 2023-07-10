resource "aws_s3_bucket" "fronts-bucketttttt1" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_tag_name
    Environment = var.bucket_tag_environment
  }
}

############## Variables ######################
variable "bucket_name" {
  description = "Name of front bucket "
  type        = string
}

variable "bucket_tag_environment" {
  description = "Environment of front bucket environment tag"
  type        = string
}

variable "bucket_tag_name" {
  description = "Name of bucket tag name"
  type        = string
}

variable "cluster_name" {
  description = "Name of cluster"
  type        = string
}

variable "ecs_product_name" {
  description = "Name of product ecs"
  type        = string
}

variable "load_balancer_name" {
  description = "Name of load balancer"
  type        = string
}

variable "products_sg_name" {
  description = "Name of product security_groups"
  type        = string
}

variable "product_family_ecs_task_definition" {
  description = "Family of product ecs"
  type        = string
}

variable "product_cpu" {
  description = "CPU product"
  type        = string
}

variable "product_memory" {
  description = "Memory product"
  type        = string
}
variable "products_alb_name" {
  description = "Products alb name"
  type        = string
}

variable "products_target_group_lb_name" {
  description = "Product target group name"
  type        = string
}

variable "order_sg_name" {
  description = "Name of order security_groups"
  type        = string
}

variable "order_family_ecs_task_definition" {
  description = "Family of order ecs"
  type        = string
}

variable "order_cpu" {
  description = "CPU order"
  type        = string
}


variable "order_memory" {
  description = "Memory order"
  type        = string
}

variable "orders_alb_name" {
  description = "Orders alb name"
  type        = string
}

variable "orders_target_group_lb_name" {
  description = "Orders target group name"
  type        = string
}



variable "shipping_sg_name" {
  description = "Name of shipping security_groups"
  type        = string
}

variable "shipping_family_ecs_task_definition" {
  description = "Family of shipping ecs"
  type        = string
}

variable "shipping_cpu" {
  description = "CPU shipping"
  type        = string
}


variable "shipping_memory" {
  description = "Memory shipping"
  type        = string
}

variable "shipping_alb_name" {
  description = "Shipping alb name"
  type        = string
}

variable "shipping_target_group_lb_name" {
  description = "Shipping target group name"
  type        = string
}


variable "payment_sg_name" {
  description = "Name of payment security_groups"
  type        = string
}

variable "payment_family_ecs_task_definition" {
  description = "Family of payment ecs"
  type        = string
}

variable "payment_cpu" {
  description = "CPU payment"
  type        = string
}


variable "payment_memory" {
  description = "Memory payment"
  type        = string
}

variable "payment_alb_name" {
  description = "Payment alb name"
  type        = string
}

variable "payment_target_group_lb_name" {
  description = "Payment target group name"
  type        = string
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
    container_name   = "products"
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
      name          = "orders"
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
  name            = "orders"
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
    container_name   = "orders"
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
      name          = "shipping"
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
  name            = "shipping"
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
    container_name   = "shipping"
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
      name          = "payments"
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
  name            = "payments"
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
    container_name   = "payments"
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