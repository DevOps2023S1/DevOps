bucket_name = "bucket-frontend-app-dev"
bucket_tag_environment = "dev"
bucket_tag_name = "Bucket Dev"

cluster_name = "dev"

load_balancer_name = "load_balancer_access_dev"

vpc_id = "vpc-0af16c272bcefd646"
networks_ids = ["subnet-0f113d1b6f51fb886", "subnet-028012d4808e800ff"] 
execution_role = "arn:aws:iam::621942369834:role/LabRole"

### PRODUCTS ###
ecs_product_name = "products-service-dev"
products_sg_name = "products-sg-dev"
product_family_ecs_task_definition = "products-service-dev"
product_cpu = "256"
product_memory = "512"
products_alb_name = "products-service-alb-dev"
products_target_group_lb_name  = "products-target-group-dev"
product_container_name = "products-service-dev"

### ORDER ###
ecs_order_name = "orders-service-dev"
order_sg_name = "orders-sg-dev"
order_family_ecs_task_definition = "orders-service-dev"
order_cpu = "256"
order_memory = "512"
orders_alb_name = "orders-service-alb-dev"
orders_target_group_lb_name  = "orders-target-group-dev"
order_container_name = "orders-service-dev"

### SHIPPING ###
ecs_shipping_name = "shipping-service-dev"
shipping_sg_name = "shipping-sg-dev"
shipping_family_ecs_task_definition = "shipping-service-dev"
shipping_cpu = "256"
shipping_memory = "512"
shipping_alb_name = "shipping-service-alb-dev"
shipping_target_group_lb_name  = "shipping-target-group-dev"
shipping_container_name = "shipping-service-dev"

### PAYMENTS ###
ecs_payments_name = "payments-service-dev"
payment_sg_name = "payments-sg-dev"
payment_family_ecs_task_definition = "payments-service-dev"
payment_cpu = "256"
payment_memory = "512"
payment_alb_name = "payments-service-alb-dev"
payment_target_group_lb_name  = "payments-target-group-dev"
payment_container_name = "payments-service-dev"