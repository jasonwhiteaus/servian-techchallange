#Create ECS Cluster
resource "aws_ecs_cluster" "tc_ecs_cluster" {
  name  = "tc_ecs_cluster"
}

resource "aws_ecs_service" "tc_ecs_service" {
  name            = "tc-ecs-service"
  cluster         = aws_ecs_cluster.tc_ecs_cluster.id
  task_definition = aws_ecs_task_definition.tc_ecs_taskdefinition_serve.arn
  scheduling_strategy = "REPLICA"
  desired_count   = 1
  network_configuration {
    assign_public_ip = true
    subnets = toset(aws_subnet.tc_public_subnet_group.*.id)
    security_groups = [ aws_security_group.tc_alb_secg.id ]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.tc_alb_tg.arn
    container_name   = "tc-ecs-container-serve"
    container_port   = 3000
  }
  deployment_controller {
    type = "ECS"
  }
  launch_type = "FARGATE"
  depends_on  = [aws_lb_listener.tc_alb_listener] 
  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_ecs_task_definition" "tc_ecs_taskdefinition_serve" {
  family          = "techchallenge_task_serve"
  requires_compatibilities = [ "FARGATE" ]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = aws_iam_role.tc_ecs_tasks_execution_role.arn
  container_definitions = jsonencode([
    {
      name          = "tc-ecs-container-serve"
      image         = "servian/techchallengeapp:latest"
      command       = [ "serve" ]
      environment   =  [
        { "name": "VTT_DBUSER", "value" : var.tc_dbusername },
        { "name": "VTT_DBPASSWORD", "value" : random_password.password.result },
        { "name": "VTT_DBNAME", "value" : var.tc_dbname },
        { "name": "VTT_DBHOST", "value" : split(":", aws_db_instance.tc_rds_db.endpoint)[0] },
        { "name": "VTT_DBPORT", "value" : split(":", aws_db_instance.tc_rds_db.endpoint)[1] },
        { "name": "VTT_LISTENPORT", "value" : "3000" },
        { "name": "VTT_LISTENHOST", "value" : " " }
      ]
      essential     = true
      portMappings  = [ { containerPort = 3000 } ]
    }])
}

resource "aws_ecs_task_definition" "tc_ecs_taskdefinition_updatedb" {
  family          = "techchallenge_task_updatedb"
  requires_compatibilities = [ "FARGATE" ]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = aws_iam_role.tc_ecs_tasks_execution_role.arn
  container_definitions = jsonencode([
    {
      name            = "tc-ecs-container-updatedb"
      image           = "servian/techchallengeapp:latest"
      command         = [ "updatedb", "--skip-create-db" ]
      environment     =  [
        { "name": "VTT_DBUSER", "value" : var.tc_dbusername },
        { "name": "VTT_DBPASSWORD", "value" : random_password.password.result },
        { "name": "VTT_DBNAME", "value" : var.tc_dbname },
        { "name": "VTT_DBHOST", "value" : split(":", aws_db_instance.tc_rds_db.endpoint)[0] },
        { "name": "VTT_DBPORT", "value" : split(":", aws_db_instance.tc_rds_db.endpoint)[1] },
        { "name": "VTT_LISTENPORT", "value" : "3000" },
        { "name": "VTT_LISTENHOST", "value" : " " }      
      ]
      essential     = true
    }])
}

data "aws_iam_policy_document" "tc_ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "tc_ecs_tasks_execution_role" {
  name               = "tc-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.tc_ecs_tasks_execution_role.json
}

resource "aws_iam_role_policy_attachment" "tc_ecs_tasks_execution_role" {
  role       = aws_iam_role.tc_ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
