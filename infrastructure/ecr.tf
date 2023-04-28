#Elastic Container Repository
#This will allow us to create repositories for each container
resource "aws_ecr_repository" "repo" {
  name = local.app_name
  tags = local.tags
}