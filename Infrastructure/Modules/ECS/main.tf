resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.prefix}-ecs-cluster-regisrty"

  tags = {
    name = "${var.prefix}-ecs-cluster-regisrty"
  }
}

data "template_file" "container_definitions" {
  template = file(var.container_definitions_json)
  vars = {
    container_name  = "schema-registry"
    container_image = "${var.container_image}"
    fargate_cpu     = var.cpu
    fargate_memory  = var.memory
    log_group_name  = var.cloudwatch_log_group
    region          = var.region
    container_port  = var.container_port
    host_port       = var.container_port
    host_name       = aws_lb.lb.dns_name
    msk_bootstrap   = var.kafka_bootstrap
  }
}

resource "aws_ecs_task_definition" "aws_ecs_task_definition" {
  family                   = "schema-registry"
  execution_role_arn       = aws_iam_role.ecs_iam_role.arn
  task_role_arn            = aws_iam_role.ecs_iam_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = data.template_file.container_definitions.rendered
}

resource "aws_ecs_service" "aws_ecs_service" {
  name             = "${var.prefix}-ecs-service-registry"
  cluster          = aws_ecs_cluster.ecs_cluster.id
  task_definition  = aws_ecs_task_definition.aws_ecs_task_definition.arn
  launch_type      = "FARGATE"
  platform_version = var.service_platform_version
  desired_count    = var.service_desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent = var.deployment_maximum_percent
  network_configuration {
    security_groups  = var.ecs_security_groups
    subnets          = var.subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = aws_ecs_task_definition.aws_ecs_task_definition.family
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.lb_listener]
}

resource "aws_lb" "lb" {
  name               = "${var.prefix}-regisrty-lb"
  internal           = true
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = var.lb_security_groups

  tags = {
    name = "${var.prefix}-regisrty-lb"
  }
}

resource "aws_lb_target_group" "lb_tg" {
  name        = "${aws_lb.lb.name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    
  }

  tags = {
    name = "${aws_lb.lb.name}-tg"
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = tostring(var.lb_port)
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

resource "aws_iam_role" "ecs_iam_role" {
  name               = "${var.prefix}-ecs-iam-role"
  assume_role_policy = file(var.ecs_iam_role)
}

data "template_file" "ecs_iam_policy" {
  template = file(var.ecs_iam_policy)
  vars = {
    region       = var.region
    account_id   = var.account_id
    cluster_name = var.msk_cluster_name
  }
}


resource "aws_iam_policy" "ecs_iam_policy" {
  name   = "${var.prefix}-ecs-iam-policy"
  policy = data.template_file.ecs_iam_policy.rendered
}

resource "aws_iam_role_policy_attachment" "ecs_attach_policy" {
  role       = aws_iam_role.ecs_iam_role.name
  policy_arn = aws_iam_policy.ecs_iam_policy.arn
}