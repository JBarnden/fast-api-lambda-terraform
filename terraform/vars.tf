variable "region" {
  type        = string
  description = "The region to deploy the infrastructure to"
  default     = "eu-central-1"
}

variable "profile" {
  type        = string
  description = "The profile to use for the AWS CLI"
  default     = "default"
}

variable "project_name" {
  type        = string
  description = "The name of the project used to identify the resources"
  default     = "lambda-api-demo"
}

variable "environment" {
  type        = string
  description = "The environment to deploy the infrastructure to"
  default     = "default"
}

variable "demo_environment_variable" {
  type        = string
  description = "A demo environment variable"

  default = "Hello from default value!"
}

variable "secret_key" {
  type        = string
  description = "Example secret to override from secret.auto.tfvars"
  default     = ""
}

variable "ecr_image_retention_days" {
  type        = number
  description = "The number of days to retain the ECR image"
  default     = 14
}

variable "enable_cdn" {
  type        = bool
  description = "Whether to enable the CDN"
  default     = false
}

# CDN won't be created if these variables are not set
variable "cdn_secret_key" {
  type        = string
  description = "The secret key the CDN will pass as a header to the API for verification"
  default     = ""
}

# Certificate will need to be in us-east-1 for CloudFront
variable "acm_certificate_arn" {
  type        = string
  description = "The ARN of the ACM certificate from us-east-1 to use for the CDN"
  default     = ""
}

variable "route_53_domain" {
  type        = string
  description = "The domain to use for the CDN"
  default     = ""
}
