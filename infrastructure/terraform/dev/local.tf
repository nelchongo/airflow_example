#Example of the execution variables

locals {
    app_name = "data-analytics"
    app_port = 8080
    
    #RDS
    rds_instance_size = "db.t3.micro" #Free tear
    rds_allocated_storage = 20
    rds_storage_type      = "gp2"
    rds_storage_iops      = 0
    rds_storage_encrypted = true
    rds_enable_performance_insights = true

    #ECS
    containers_count = 1
    certificate_arn = "arn:aws:acm:us-east-1:549532010890:certificate/91e58fde-b46c-457c-9287-5f8cce9ed885"
    tags = {
        env = "dev"
        app = "data-analytics"
    }

    #LB
    health_check_path = "/health"
}