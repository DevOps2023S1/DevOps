bucket_name = "bucket-frontend-app-test"
bucket_tag_environment = "test"
bucket_tag_name = "Bucket Test"

cluster_name = "test"

load_balancer_name = "load_balancer_access_test"

vpc_id = "vpc-0af16c272bcefd646"
networks_ids = ["subnet-0f113d1b6f51fb886", "subnet-028012d4808e800ff"] 
execution_role = "arn:aws:iam::621942369834:role/LabRole"

### PRODUCTS ###
ecs_product_name = "products-service-test"
products_sg_name = "products-sg-test"
product_family_ecs_task_definition = "products-service-test"
product_cpu = "256"
product_memory = "512"
products_alb_name = "products-service-alb-test"
products_target_group_lb_name  = "products-target-group-test"
product_container_name = "products-service-test"

### ORDER ###
ecs_order_name = "orders-service-test"
order_sg_name = "orders-sg-test"
order_family_ecs_task_definition = "orders-service-test"
order_cpu = "256"
order_memory = "512"
orders_alb_name = "orders-service-alb-test"
orders_target_group_lb_name  = "orders-target-group-test"
order_container_name = "orders-service-test"

### SHIPPING ###
ecs_shipping_name = "shipping-service-test"
shipping_sg_name = "shipping-sg-test"
shipping_family_ecs_task_definition = "shipping-service-test"
shipping_cpu = "256"
shipping_memory = "512"
shipping_alb_name = "shipping-service-alb-test"
shipping_target_group_lb_name  = "shipping-target-group-test"
shipping_container_name = "shipping-service-test"

### PAYMENTS ###
ecs_payments_name = "payments-service-test"
payment_sg_name = "payments-sg-test"
payment_family_ecs_task_definition = "payments-service-test"
payment_cpu = "256"
payment_memory = "512"
payment_alb_name = "payments-service-alb-test"
payment_target_group_lb_name  = "payments-target-group-test"
payment_container_name = "payments-service-test"