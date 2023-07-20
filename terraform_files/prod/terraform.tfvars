bucket_name = "bucket-frontend-app-production"
bucket_tag_environment = "prod"
bucket_tag_name = "Prod"

cluster_name = "prod"

load_balancer_name = "load_balancer_access_prod"

vpc_id = "vpc-0af16c272bcefd646"
networks_ids = ["subnet-0f113d1b6f51fb886", "subnet-028012d4808e800ff"] 
execution_role = "arn:aws:iam::621942369834:role/LabRole"

### PRODUCTS ###
ecs_product_name = "products-service-prod"
products_sg_name = "products-sg-prod"
product_family_ecs_task_definition = "products-service-prod"
product_cpu = "256"
product_memory = "512"
products_alb_name = "products-service-alb-prod"
products_target_group_lb_name  = "products-target-group-prod"
product_container_name = "products-service-prod"

### ORDER ###
ecs_order_name = "orders-service-prod"
order_sg_name = "orders-sg-prod"
order_family_ecs_task_definition = "orders-service-prod"
order_cpu = "256"
order_memory = "512"
orders_alb_name = "orders-service-alb-prod"
orders_target_group_lb_name  = "orders-target-group-prod"
order_container_name = "orders-service-prod"

### SHIPPING ###
ecs_shipping_name = "shipping-service-prod"
shipping_sg_name = "shipping-sg-prod"
shipping_family_ecs_task_definition = "shipping-service-prod"
shipping_cpu = "256"
shipping_memory = "512"
shipping_alb_name = "shipping-service-alb-prod"
shipping_target_group_lb_name  = "shipping-target-group-prod"
shipping_container_name = "shipping-service-prod"

### PAYMENTS ###
ecs_payments_name = "payments-service-prod"
payment_sg_name = "payments-sg-prod"
payment_family_ecs_task_definition = "payments-service-prod"
payment_cpu = "256"
payment_memory = "512"
payment_alb_name = "payments-service-alb-prod"
payment_target_group_lb_name  = "payments-target-group-prod"
payment_container_name = "payments-service-prod"