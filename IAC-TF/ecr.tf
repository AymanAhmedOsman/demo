# Step 1: Create an ECR Repository
resource "aws_ecr_repository" "my_private_ecr" {
  name                 = "my-private-repo"  # Name of your ECR repository
  image_tag_mutability = "MUTABLE"          # Set to "IMMUTABLE" if you want to prevent overwriting tags

  tags = {
    Environment = "development"
    Project     = "my-project"
  }
}

# Step 2: Output the ECR repository URI
output "ecr_repository_uri" {
  value = aws_ecr_repository.my_private_ecr.repository_url
}
