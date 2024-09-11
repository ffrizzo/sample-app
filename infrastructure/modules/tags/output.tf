output "tags" {
  value = {
    application = var.application
    environment = var.environment
    terraform   = "true"
  }
}
