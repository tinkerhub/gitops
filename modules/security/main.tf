# security groups
resource "aws_security_group" "supertokens_ecs" {
  vpc_id = var.ecs_vpc_id
  name   = "${var.environment}-supertokens"

  ingress {
    to_port         = 3567
    from_port       = 3567
    protocol        = "tcp"
    security_groups = [aws_security_group.platform_lambda.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "platform_lambda" {
  vpc_id = var.ecs_vpc_id
  name   = "${var.environment}-plaform_lambda"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
