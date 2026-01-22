# --- ECR ---

resource "aws_ecr_repository" "api" {
  name                 = "${var.project_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "api" {
  repository = aws_ecr_repository.api.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than ${var.ecr_image_retention_days} days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": ${var.ecr_image_retention_days}
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

# --- Build & push image ---

locals {
  repo_url = aws_ecr_repository.api.repository_url
}

resource "null_resource" "image" {
  triggers = {
    # Trigger a rebuild of the image if any of theses files in the code directory change
    hash = md5(join(
      "-",
      [
        for x in concat(
          tolist(fileset("../code", "*.py")),
          tolist(fileset("../code", "*.txt")),
          tolist(fileset("../code", "Dockerfile"))
        ) : filemd5("../code/${x}")
      ]
    ))
  }

  provisioner "local-exec" {
    command = <<EOF
      set -e 
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.repo_url}
      # Use buildx with docker-container driver for cross-platform support
      docker buildx create --use --name lambda-builder --driver docker-container --bootstrap 2>/dev/null || docker buildx use lambda-builder || true
      # Push a Docker v2 (non-OCI) manifest directly to ECR for Lambda compatibility
      docker buildx build --platform linux/arm64 --provenance=false --sbom=false --output type=registry,oci-mediatypes=false --push -t ${local.repo_url}:latest ../code
      echo "Image pushed to ${local.repo_url}:latest"
    EOF
  }
}

data "aws_ecr_image" "latest" {
  repository_name = aws_ecr_repository.api.name
  image_tag       = "latest"
  depends_on      = [null_resource.image]

  # Add a lifecycle block to handle timing issues
  lifecycle {
    postcondition {
      condition     = self.id != ""
      error_message = "ECR image was not found after push completed."
    }
  }
}
