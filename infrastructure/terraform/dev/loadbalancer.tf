data "aws_caller_identity" "current" {}


# ALB and its dependencies
resource "aws_lb_target_group" "tg" {
    name        = local.app_name
    port        = local.app_port
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = module.app_vpc.vpc_id
    health_check {
        path                = "/ping/"
        matcher             = "200"
        interval            = 15
        healthy_threshold   = 3
        unhealthy_threshold = 2
    }

    deregistration_delay    = 120
    tags                    = local.tags
}

resource "aws_security_group" "lb" {
    name        = "${local.app_name}-loadbalancer"
    description = "Security Group for ${local.app_name} load balancer"
    vpc_id      = module.app_vpc.vpc_id
    tags        = local.tags
}

resource "aws_security_group_rule" "allow_egress_lb" {
    description       = "Allow all outgoing traffic"
    type              = "egress"
    protocol          = "all"
    from_port         = 0
    to_port           = 0
    cidr_blocks       = ["0.0.0.0/0"]
    ipv6_cidr_blocks  = ["::/0"]
    security_group_id = aws_security_group.lb.id
}
resource "aws_security_group_rule" "allow_cidrs_http_lb" {
    count             = 1
    description       = "Allow incoming http traffic from clients"
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = []
    ipv6_cidr_blocks  = []
    security_group_id = aws_security_group.lb.id
}
resource "aws_security_group_rule" "allow_cidrs_https_lb" {
    count             = 1
    description       = "Allow incoming https traffic from clients"
    type              = "ingress"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = []
    ipv6_cidr_blocks  = []
    security_group_id = aws_security_group.lb.id
}
resource "aws_security_group_rule" "allow_sg_http_lb" {
    for_each                 = toset([module.app_tg_sg.this_security_group_id])
    description              = "Allow incoming http traffic from clients"
    type                     = "ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = each.key
    security_group_id        = aws_security_group.lb.id
}
resource "aws_security_group_rule" "allow_sg_https_lb" {
    for_each                 = toset([module.app_tg_sg.this_security_group_id])
    description              = "Allow incoming https traffic from clients"
    type                     = "ingress"
    from_port                = 443
    to_port                  = 443
    protocol                 = "tcp"
    source_security_group_id = each.key
    security_group_id        = aws_security_group.lb.id
}

resource "aws_lb" "lb" {
    name               = local.app_name
    internal           = true
    load_balancer_type = "application"
    security_groups    = [aws_security_group.lb.id]
    subnets            = module.app_vpc.private_subnets
    tags               = local.tags

    #We can add logs in here
}

resource "aws_lb_listener" "http_listener" {
    load_balancer_arn = aws_lb.lb.arn
    port              = 80
    protocol          = "HTTP"
    default_action {
        type = "redirect"
        redirect {
            port        = 443
            protocol    = "HTTPS"
            status_code = "HTTP_301"
        }
    }
    tags = local.tags
}

resource "aws_lb_listener" "https_listener" {
    load_balancer_arn = aws_lb.lb.arn
    port              = 443
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
    certificate_arn   = local.certificate_arn
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.tg.arn
    }
    tags = local.tags
}