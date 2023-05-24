resource "aws_ecs_cluster" "ecs" {
  name = "test"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}