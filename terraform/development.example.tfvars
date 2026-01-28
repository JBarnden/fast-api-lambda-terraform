environment = "development"

# AWS profile to use for the AWS CLI (set this in secrets.auto.tfvars if you want it used across all environments)
profile = "default"
# AWS region to deploy the infrastructure to (set this in secrets.auto.tfvars if you want it used across all environments)
region = "eu-central-1"

demo_environment_variable = "I am a demo environment variable for development"
project_name              = "lambda-api"
ecr_image_retention_days  = 1

# Optionally enable and configure the CDN for API custom domain
enable_cdn          = false
cdn_secret_key      = "your-cdn-secret-key-bleep-bloop"
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
route_53_domain     = "yourdomain.com"
