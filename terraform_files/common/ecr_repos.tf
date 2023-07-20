resource "aws_ecr_repository" "orders-service" {
  name                 = "orders-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "shipping-service" {
  name                 = "shipping-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "payments-service" {
  name                 = "payments-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "products-service" {
  name                 = "products-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "frontend-app" {
  name                 = "frontend-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "orders_url_repo" {
  value = aws_ecr_repository.orders-service.repository_url
}

output "shipping_url_repo" {
  value = aws_ecr_repository.shipping-service.repository_url
}

output "payments_url_repo" {
  value = aws_ecr_repository.payments-service.repository_url
}

output "products_url_repo" {
  value = aws_ecr_repository.products-service.repository_url
}

output "frontend_app_url_repo" {
  value = aws_ecr_repository.frontend-app.repository_url
}