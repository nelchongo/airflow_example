locals {
  rds_name = "${local.app_name}-rds"
  rds_secret_name = "${local.tags.env}/${local.rds_name}/postgres"
}

#Secret Manager
resource "random_password" "rds_password" {
  count   = 1
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "rds_pass" {
  count = 1
  name  = local.rds_secret_name
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  count         = 1
  secret_id     = aws_secretsmanager_secret.rds_pass[0].id
  secret_string = random_password.rds_password[0].result
}

#Networking
resource "aws_db_subnet_group" "main" {
  count      = 1
  name       = "${local.rds_name}-${local.tags.env}-rds-subnet-group"
  subnet_ids = local.private_subnets
  tags       = local.tags
}

resource "aws_security_group" "rds" {
  count       = 1
  name        = "${local.rds_name}-${local.tags.env}-rds-sg"
  description = "Application database - ${local.app_name}"
  vpc_id      = local.vpc_id
  tags        = local.tags
}

resource "aws_security_group_rule" "allow_ingress_rds" {
  count             = 1
  description       = "Allow all inbound traffic"
  type              = "ingress"
  protocol          = "-1"
  from_port         = 5432
  to_port           = 5432
  cidr_blocks       = ["172.31.0.0/16"]
  security_group_id = aws_security_group.rds[0].id
}

resource "aws_security_group_rule" "allow_egress_rds" {
  count             = 1
  description       = "Allow all outgoing traffic"
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.rds[0].id
}

# resource "aws_security_group_rule" "allow_dbaccess_from_instances_to_rds" {
#   count                    = 1
#   description              = "Allow database access from application instances"
#   type                     = "ingress"
#   from_port                = 5432
#   to_port                  = 5432
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.instances.id
#   security_group_id        = aws_security_group.rds[0].id
# }

resource "aws_security_group_rule" "allow_dbaccess_from_given_ips" {
  count                    = length(local.rds_allowed_ip4_cidrs) > 0 ? 1 : 0
  description              = "Allow database access from each ranges"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  cidr_blocks              = local.rds_allowed_ip4_cidrs
  security_group_id        = aws_security_group.rds[0].id
}

resource "aws_security_group_rule" "allow_dbaccess_from_given_sg" {
  for_each                 = toset(local.rds_allowed_sg)
  description              = "Allow database access from each security group"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = each.key
  security_group_id        = aws_security_group.rds[0].id
}

#Roles
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count               = 1
  name                = "${local.rds_name}-rds-monitoring"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]

  assume_role_policy  = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Sid = ""
            Effect = "Allow"
            Principal = {
                Service = "monitoring.rds.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
    ]
  })

  tags = local.tags
}

#RDS
data "aws_availability_zones" "current" {
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

resource "aws_db_instance" "this" {
  count = 1
  # db_name           = local.rds_name
  identifier        = local.rds_name
  engine            = "postgres"
  engine_version    = "13.4"
  instance_class    = local.rds_instance_size
  allocated_storage = local.rds_allocated_storage
  storage_type      = local.rds_storage_type
  iops              = null
  storage_encrypted = local.rds_storage_encrypted

  username = "postgres"
  password = aws_secretsmanager_secret_version.rds_secret_version[0].secret_string
  port     = 5432

  vpc_security_group_ids       = [aws_security_group.rds[0].id]
  db_subnet_group_name         = aws_db_subnet_group.main[0].name
  parameter_group_name         = "default.postgres13"
  option_group_name            = "default:postgres-13"
  performance_insights_enabled = local.rds_enable_performance_insights

  availability_zone   = data.aws_availability_zones.current.names[0]
  multi_az            = false
  publicly_accessible = false

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  maintenance_window          = "tue:04:00-tue:05:00"
  backup_window               = null
  backup_retention_period     = 30
  deletion_protection         = true
  skip_final_snapshot         = true
  monitoring_interval         = 0
  monitoring_role_arn         = null
  apply_immediately           = true
  tags                        = local.tags
}
