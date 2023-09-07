module "application" {
    source = "git@github.com:NelsonECandia/fs_infrastructure.git?ref=v0.8"
    app_name = "airflow"
    tags = {
        env = "dev"
        app_name = "airflow"
    }
    app_port = 8080
    lb_health_check_path = "/health"
    lb_certificate_arn = "arn:aws:acm:us-east-1:549532010890:certificate/a2eba18a-1b40-4eb8-8650-f8ad824828c2"
    route_53_hosted_zone_id = "Z04211931VZIR5O4OUFHD"
    # tg_api_token = "" #SET ONLY ON FIRST START
}