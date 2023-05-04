resource "aws_iam_role" "execution" {
  description = "Role to be used by Fargate."
  name        = "${local.app_name}-execution"
  tags        = local.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EcsAssumeRole"
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role" "task" {
  description = "Role to be used by application instances/containers/tasks."
  name        = "${local.app_name}-task"
  tags        = local.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EcsAssumeRole"
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })
}