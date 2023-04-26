#Elastic Container Repository
#This will allow us to create repositories for each container
resource "aws_ecr_repository" "repo" {
  name = var.app_name
  tags = local.tags
}