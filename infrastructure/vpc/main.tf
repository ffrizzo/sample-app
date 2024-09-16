module "tags" {
  source      = "../modules/tags"
  application = "sample-app"
  environment = "dev"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "sample-vpc"
  cidr = "10.0.0.0/16"

  azs = ["us-west-1a", "us-west-1b", "us-west-1c"]

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_tags = {
    type = "private"
  }

  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnet_tags = {
    type = "public"
  }

  create_igw         = true
  enable_nat_gateway = true

  tags = module.tags.tags
}
