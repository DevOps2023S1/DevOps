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

variable "ecs_order_name" {
  description = "Name of order ecs"
  type        = string
}

variable "ecs_shipping_name" {
  description = "Name of shipping ecs"
  type        = string
}

variable "ecs_payments_name" {
  description = "Name of payment ecs"
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

variable "product_container_name" {
  description = "Product container name"
  type        = string
}

variable "shipping_container_name" {
  description = "Shipping container name"
  type        = string
}

variable "order_container_name" {
  description = "Order container name"
  type        = string
}

variable "payment_container_name" {
  description = "Payment container name"
  type        = string
}
