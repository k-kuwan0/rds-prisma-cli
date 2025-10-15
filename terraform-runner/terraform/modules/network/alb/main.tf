#==========================================================================#
# Application Load Balancer                                                #
#==========================================================================#
resource "aws_lb" "main" {
  name               = "${var.service_prefix}-alb"
  load_balancer_type = local.load_balancer_type
  internal           = var.internal
  ip_address_type    = var.ip_address_type
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids

  tags = {
    Name = "${var.service_prefix}-alb"
  }
}

#==========================================================================#
# Target Group                                                             #
#==========================================================================#
resource "aws_lb_target_group" "main" {
  for_each = var.target_groups

  name             = "${var.service_prefix}-${each.key}"
  port             = each.value.port
  protocol         = each.value.protocol
  protocol_version = each.value.protocol_version
  target_type      = each.value.target_type
  vpc_id           = var.vpc_id

  dynamic "health_check" {
    for_each = each.value.health_check
    content {
      enabled             = health_check.value.enabled
      healthy_threshold   = health_check.value.healthy_threshold
      unhealthy_threshold = health_check.value.unhealthy_threshold
      timeout             = health_check.value.timeout
      interval            = health_check.value.interval
      path                = health_check.value.path
      matcher             = health_check.value.matcher
      port                = health_check.value.port
      protocol            = health_check.value.protocol
    }
  }

  tags = {
    Name = "${var.service_prefix}-${each.key}"
  }
}

#==========================================================================#
# Target Group Attachment                                                  #
#==========================================================================#
resource "aws_lb_target_group_attachment" "main" {
  for_each = {
    for target_config in flatten([
      for key, target_groups in var.target_groups : [
        for target_index, target in target_groups.targets : {
          key              = "${key}-${target_index}"
          target_group_key = key
          target_id        = target.id
          port             = target.port
        }
      ]
    ]) : target_config.key => target_config
  }

  target_group_arn = aws_lb_target_group.main[each.value.target_group_key].arn
  target_id        = each.value.target_id
  port             = each.value.port
}

#==========================================================================#
# Listener                                                                 #
#==========================================================================#
resource "aws_lb_listener" "main" {
  for_each = {
    for listener_config in flatten([
      for key, target_groups in var.target_groups : [
        for listener_index, listener in target_groups.listeners : {
          key              = "${key}-${listener_index}"
          target_group_key = key
          port             = listener.port
          protocol         = listener.protocol
          type             = listener.type
        }
      ]
    ]) : listener_config.key => listener_config
  }

  load_balancer_arn = aws_lb.main.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = each.value.type
    target_group_arn = aws_lb_target_group.main[each.value.target_group_key].arn
  }

  tags = {
    Name = "${var.service_prefix}-${each.key}"
  }
}
