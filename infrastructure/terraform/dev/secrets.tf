#Airflow host
resource "aws_secretsmanager_secret" "airflow_host" {
  count = 1
  name  = "dev/${module.application.app_name}/back-end-host"
}

resource "aws_secretsmanager_secret" "airflow_celery_host" {
  count = 1
  name  = "dev/${module.application.app_name}/celery-back-end-host"
}

resource "aws_iam_role_policy" "fargate_access_secrets" {
  name = "access_secrets"
  role = module.application.ecs_execution_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "SecretsAccess",
        Action = [
          "kms:Decrypt",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:ListSecrets"
        ]
        Resource = [
          aws_secretsmanager_secret.airflow_host[0].id, aws_secretsmanager_secret.airflow_celery_host[0].id
        ]
        Effect   = "Allow"
      }
    ]
  })
}
