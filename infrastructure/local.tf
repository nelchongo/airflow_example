#Example of the execution variables

locals {
    app_name = "data-analytics"
    app_port = 8080
    #Network
    #Subnets have been created manually
    private_subnets = ["subnet-0800d7671cd1a4fb4", "subnet-09ca4a3c63091d225", "subnet-04695e1fc8fab7600", "subnet-0ef730d000836f59e"]
    public_subnets = ["subnet-09194ecdcbb992ed7", "subnet-0d849be83f592d041", "subnet-0430f3d3cde840c8d"]
    vpc_id = "vpc-0f77fe96015a91bed"
    
    #RDS
    rds_instance_size = "db.t3.micro" #Free tear
    rds_allocated_storage = 20
    rds_storage_type      = "gp2"
    rds_storage_iops      = 0
    rds_storage_encrypted = true
    rds_enable_performance_insights = true
    rds_allowed_ip4_cidrs = []
    rds_allowed_sg = []
    tags = {
        env = "dev"
        app = "data-analytics"
    }
}