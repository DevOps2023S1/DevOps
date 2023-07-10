bucket_name = "bucket-productionnnnn"
bucket_tag_environment = "prod"
bucket_tag_name = "Prod"

cluster_name = "production"
ecs_product_name = "products-prod"
load_balancer_name = "load_balancer_acess_prod"
products_sg_name = "products-sg-prod"
product_family_ecs_task_definition = "product-prod"
product_cpu = "512"
product_memory = "1024"
products_alb_name = "products-alb-prod"
products_target_group_lb_name  = "products-target-group-prod"

### ORDER ###

order_sg_name = "order-sg-prod"
order_family_ecs_task_definition = "order-prod"
order_cpu = "256"
order_memory = "512"
orders_alb_name = "products-alb-prod"
orders_target_group_lb_name  = "orders-target-group-prod"

### SHIPPING ###

shipping_sg_name = "shipping-sg-prod"
shipping_family_ecs_task_definition = "shipping-prod"
shipping_cpu = "256"
shipping_memory = "512"
shipping_alb_name = "shipping-alb-prod"
shipping_target_group_lb_name  = "shipping-target-group-prod"

### PAYMENTS ###

payment_sg_name = "payment-sg-prod"
payment_family_ecs_task_definition = "payment-prod"
payment_cpu = "256"
payment_memory = "512"
payment_alb_name = "payment-alb-prod"
payment_target_group_lb_name  = "payment-target-group-prod"