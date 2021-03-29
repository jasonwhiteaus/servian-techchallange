resource "aws_appautoscaling_target" "tc_ecs_target" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.tc_ecs_cluster.name}/${aws_ecs_service.tc_ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "tc_autoscale_policycpu" {
  name = "tc_autoscale_policycpu"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.tc_ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.tc_ecs_target.scalable_dimension
  service_namespace = aws_appautoscaling_target.tc_ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 60
  }
}
