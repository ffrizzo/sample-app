data "aws_ecr_repository" "repository" {
  name = "sample-app"
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.11.4"

  cluster_name = "sample-app"

  services = {
    sample-app = {
      cpu    = 512
      memory = 1024

      container_definitions = {
        sample-app = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "${data.aws_ecr_repository.repository.repository_url}:${var.image_tag}"

          port_mappings = [
            {
              name          = "app"
              containerPort = 8080
              protocol      = "tcp"
            }
          ]

          enable_cloudwatch_logging = true
        }

      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["ecs-task"].arn
          container_name   = "sample-app"
          container_port   = 8080
        }
      }

      subnet_ids = data.aws_subnets.private_subnets.ids
      security_group_rules = {
        alb_ingress = {
          type                     = "ingress"
          from_port                = 8080
          to_port                  = 8080
          protocol                 = "tcp"
          source_security_group_id = module.alb.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

}
