resource "aws_s3_bucket" "frontend_images_repo" {
    bucket = "devops-frontend-builded-images-repository"

    tags = {
        Name        = "Images frontend repo"
        Environment = "Prod"
    }
}