locals {
  rds_name = "${var.app_name}_rds"
  rds_secret_name = "${var.tags.env}/${local.rds_name}/postgres"
}

#Secret Manager
resource "random_password" "rds_password" {
  count   = var.create_rds ? 1 : 0
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "rds_pass" {
  count = var.create_rds ? 1 : 0
  name  = local.rds_secret_name
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  count         = var.create_rds ? 1 : 0
  secret_id     = aws_secretsmanager_secret.rds_pass[0].id
  secret_string = random_password.rds_password[0].result
}