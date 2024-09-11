module "tags" {
  source      = "../modules/tags"
  application = "sample-app"
  environment = "dev"
}

data "aws_vpc" "vpc" {
  tags = module.tags.tags
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = merge(
    { type = "private" },
    module.tags.tags
  )
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = merge(
    { type = "public" },
    module.tags.tags
  )
}
