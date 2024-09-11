module "tags" {
  source      = "../modules/tags"
  application = "sample-app"
  environment = "dev"
}

resource "aws_ecr_repository" "ecs" {
  name = "sample-app"
  tags = module.tags.tags
}
