provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  region = "eu-west-3"
  name   = "test"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  container_name_front = "frontend"
  container_port_front = 3000
  container_name_api = "api"
  container_port_api = 3001
  container_name_streamlit_1 = "streamlit_1"
  container_port_streamlit_1 = 3001
  container_name_streamlit_2 = "streamlit_2"
  container_port_streamlit_2 = 3001

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "337671252064.dkr.ecr.eu-west-3.amazonaws.com/central-service:latest"
  }
}

resource "aws_service_discovery_http_namespace" "this" {
  name        = local.name
  description = "CloudMap namespace for ${local.name}"
  tags        = local.tags
}


module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  cluster_name = local.name

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  services = {
    frontend = {
      cpu    = 1024
      memory = 4096

      # Container definition(s)
      container_definitions = {


        (local.container_name_front) = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "337671252064.dkr.ecr.eu-west-3.amazonaws.com/central-service:latest"


          port_mappings = [
            {
              name          = local.container_name_front
              containerPort = local.container_port_front
              hostPort      = local.container_port_front
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false
          memory_reservation = 100
        }
      }

      service_connect_configuration = {
        namespace = aws_service_discovery_http_namespace.this.arn
        service = {
          client_alias = {
            port     = local.container_port_front
            dns_name = local.container_name_front
          }
          port_name      = local.container_name_front
          discovery_name = local.container_name_front
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["frontend_ecs"].arn
          container_name   = local.container_name_front
          container_port   = local.container_port_front
        }
      }


      subnet_ids = module.vpc.public_subnets
      security_group_rules = {
        alb_ingress_3000 = {
          type                     = "ingress"
          from_port                = local.container_port_front
          to_port                  = local.container_port_front
          protocol                 = "tcp"
          description              = "Service port"
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
############################################api##################################################################

    api = {
      cpu    = 1024
      memory = 4096

      # Container definition(s)
      container_definitions = {


        (local.container_name_api) = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "337671252064.dkr.ecr.eu-west-3.amazonaws.com/fastapi-api:latest"


          port_mappings = [
            {
              name          = local.container_name_api
              containerPort = local.container_port_api
              hostPort      = local.container_port_api
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false
          memory_reservation = 100
        }
      }

      service_connect_configuration = {
        namespace = aws_service_discovery_http_namespace.this.arn
        service = {
          client_alias = {
            port     = local.container_port_api
            dns_name = local.container_name_api
          }
          port_name      = local.container_name_api
          discovery_name = local.container_name_api
        }
      }

      # load_balancer = {
      #   service = {
      #     target_group_arn = module.alb.target_groups["api_ecs"].arn
      #     container_name   = local.container_name_api
      #     container_port   = local.container_port_api
      #   }
      # }


      subnet_ids = module.vpc.public_subnets
      security_group_rules = {
        alb_ingress_3000 = {
          type                     = "ingress"
          from_port                = local.container_port_api
          to_port                  = local.container_port_api
          protocol                 = "tcp"
          description              = "Service port"
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
############################################streamlit_1##################################################################


    streamlit_1 = {
      cpu    = 1024
      memory = 4096

      # Container definition(s)
      container_definitions = {


        (local.container_name_streamlit_1) = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "337671252064.dkr.ecr.eu-west-3.amazonaws.com/streamlit_1:latest"


          port_mappings = [
            {
              name          = local.container_name_streamlit_1
              containerPort = local.container_port_streamlit_1
              hostPort      = local.container_port_streamlit_1
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false
          memory_reservation = 100
        }
      }

      service_connect_configuration = {
        namespace = aws_service_discovery_http_namespace.this.arn
        service = {
          client_alias = {
            port     = local.container_port_streamlit_1
            dns_name = local.container_name_streamlit_1
          }
          port_name      = local.container_name_streamlit_1
          discovery_name = local.container_name_streamlit_1
        }
      }

      # load_balancer = {
      #   service = {
      #     target_group_arn = module.alb.target_groups["api_ecs"].arn
      #     container_name   = local.container_name_streamlit_1
      #     container_port   = local.container_port_streamlit_1
      #   }
      # }


      subnet_ids = module.vpc.public_subnets
      security_group_rules = {
        alb_ingress_3000 = {
          type                     = "ingress"
          from_port                = local.container_port_streamlit_1
          to_port                  = local.container_port_streamlit_1
          protocol                 = "tcp"
          description              = "Service port"
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
############################################streamlit_2##################################################################

    streamlit_2 = {
      cpu    = 1024
      memory = 4096

      # Container definition(s)
      container_definitions = {


        (local.container_name_streamlit_2) = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "337671252064.dkr.ecr.eu-west-3.amazonaws.com/streamlit_2:latest"


          port_mappings = [
            {
              name          = local.container_name_streamlit_2
              containerPort = local.container_port_streamlit_2
              hostPort      = local.container_port_streamlit_2
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false
          memory_reservation = 100
        }
      }

      service_connect_configuration = {
        namespace = aws_service_discovery_http_namespace.this.arn
        service = {
          client_alias = {
            port     = local.container_port_streamlit_2
            dns_name = local.container_name_streamlit_2
          }
          port_name      = local.container_name_streamlit_2
          discovery_name = local.container_name_streamlit_2
        }
      }

      # load_balancer = {
      #   service = {
      #     target_group_arn = module.alb.target_groups["api_ecs"].arn
      #     container_name   = local.container_name_streamlit_2
      #     container_port   = local.container_port_streamlit_2
      #   }
      # }


      subnet_ids = module.vpc.public_subnets
      security_group_rules = {
        alb_ingress_3000 = {
          type                     = "ingress"
          from_port                = local.container_port_streamlit_2
          to_port                  = local.container_port_streamlit_2
          protocol                 = "tcp"
          description              = "Service port"
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

  tags = local.tags
}


module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name = local.name

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  listeners = {
    ex_http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "frontend_ecs"
      }
    }
  }

  target_groups = {
    frontend_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = local.container_port_front
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }

  tags = local.tags
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}
