module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.11.0"

  name    = "sample"
  vpc_id  = data.aws_vpc.vpc.id
  subnets = data.aws_subnets.public_subnets.ids

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    default = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.certificate_arn

      forward = {
        target_group_key = "ecs-task"
      }
    }
  }

  target_groups = {
    ecs-task = {
      name        = "sample-app"
      protocol    = "HTTP"
      port        = 8080
      target_type = "ip"

      create_attachment = false

      health_check = {
        nabled              = true
        path                = "/health_check"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 3
        matcher             = "200-299"
      }

    }
  }

  tags = module.tags.tags
}
