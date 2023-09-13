resource "aws_iam_role_policy" "fargate_access_s3" {
  name = "access_s3"
  role = "airflow-task"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "S3Access",
        Action = [
          "s3:*",
        ]
        Resource = [
          "*"
        ]
        Effect   = "Allow"
      }
    ]
  })
}