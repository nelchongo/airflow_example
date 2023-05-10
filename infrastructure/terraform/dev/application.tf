module "application" {
    source = "git@github.com:NelsonECandia/fs_infrastructure.git?ref=v0.7"
    app_name = "airflow"
    tags = {
        env = "dev"
        app_name = "airflow"
    }
    app_port = 8080
    lb_health_check_path = "/health"
    lb_certificate_arn = "arn:aws:acm:us-east-1:549532010890:certificate/91e58fde-b46c-457c-9287-5f8cce9ed885"
    route_53_hosted_zone_id = "Z04211931VZIR5O4OUFHD"
    #tg_api_token = "" SET ONLY ON FIRST START
}