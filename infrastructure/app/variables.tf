variable "image_tag" {
  description = "Defines the Docker image tag to be pulled"
  type        = string
  default     = "test"
}

variable "certificate_arn" {
  description = "ARN of the certificate to be set on ALB Target Group"
  type        = string
  default     = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
}
