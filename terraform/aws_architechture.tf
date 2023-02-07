provider "aws" {
  region = "eu-central-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "db_sg" {
  vpc_id      = data.aws_vpc.default.id
  name        = "db_sg"
  description = "Allow all inbound for Postgres"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "db_instance" {
  identifier             = "iphoneypot"
  db_name                = "iphoneypot"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.6"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  username               = "postgres"
  password               = "XaVGfUhk98v6GbL"
}

output "db_endpoint" {
  value = split(":", aws_db_instance.db_instance.endpoint)[0]
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "honeypotapp"
  execution_role_arn       = "arn:aws:iam::570736878624:role/ecsTaskExecutionRole"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 3072

  container_definitions = jsonencode([
    {
      "name" : "honeypot",
      "image" : "public.ecr.aws/s6c2y4v5/honeypot:latest",
      "cpu" : 0,
      "portMappings" : [
        {
          "name" : "honeypot-3000-tcp",
          "containerPort" : 3000,
          "hostPort" : 3000,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      "essential" : true,
      "environment" : [
        {
          "name" : "PGSQL_PORT",
          "value" : "5432"
        },
        {
          "name" : "PGSQL_USER",
          "value" : "postgres"
        },
        {
          "name" : "PGSQL_HOST",
          "value" : split(":", aws_db_instance.db_instance.endpoint)[0]
        },
        {
          "name" : "PGSQL_PASSWORD",
          "value" : "XaVGfUhk98v6GbL"
        },
        {
          "name" : "PGSQL_DATABASE",
          "value" : "iphoneypot"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "/ecs/test",
          "awslogs-region" : "eu-central-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "honeypot-cluster"
}


resource "aws_ecs_service" "ecs_service" {
  name                  = "honeypot-service"
  cluster               = aws_ecs_cluster.ecs_cluster.name
  task_definition       = aws_ecs_task_definition.ecs_task.arn
  desired_count         = 2
  launch_type           = "FARGATE"
  platform_version      = "LATEST"
  wait_for_steady_state = true

  network_configuration {
    subnets          = ["subnet-0a7abee556e7f5da8", "subnet-0561db4226c40e24e", "subnet-0512dd74937f1aa94"]
    security_groups  = ["sg-0f927b295f75d3216"]
    assign_public_ip = true
  }
}
