resource "aws_ecs_cluster" "cluster" {
  name = local.app_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = local.tags
}

resource "aws_ecs_cluster_capacity_providers" "capacity_providers" {
  cluster_name       = aws_ecs_cluster.cluster.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = local.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn
  cpu                      = 256
  memory                   = 512
  tags                     = local.tags
  container_definitions = jsonencode([
    {
      name  = local.app_name
      image = "not-existent"
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = local.app_port
        }
      ]
      essential = true
    },
  ])
}

resource "aws_ecs_service" "service" {
  name                               = local.app_name
  cluster                            = aws_ecs_cluster.cluster.id
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  task_definition                    = aws_ecs_task_definition.service.id
  desired_count                      = local.containers_count
  enable_execute_command             = true
  tags                               = local.tags
  propagate_tags                     = "TASK_DEFINITION"
  health_check_grace_period_seconds  = 0

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.id
    container_name   = local.app_name
    container_port   = local.app_port
  }

  network_configuration {
    security_groups  = [aws_security_group.instances.id]
    subnets          = module.app_vpc.private_subnets
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
}

resource "aws_security_group" "instances" {
  name        = "${local.app_name}-instances"
  description = "Security Group for ${local.app_name} instances/containers/tasks"
  vpc_id      = module.app_vpc.vpc_id
  tags        = local.tags
}

resource "aws_security_group_rule" "allow_egress_instances" {
  description       = "Allow all outgoing traffic"
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.instances.id
}

resource "aws_security_group_rule" "allow_http_from_loadbalancer_to_instances" {
  description              = "Allow incoming http traffic from the load balancer"
  type                     = "ingress"
  from_port                = local.app_port
  to_port                  = local.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb.id
  security_group_id        = aws_security_group.instances.id
}