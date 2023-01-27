# security groups
resource "aws_security_group" "supertokens_ecs" {
  vpc_id = var.ecs_vpc_id
  name   = "${var.environment}-supertokens"

  ingress {
    to_port         = 3567
    from_port       = 3567
    protocol        = "tcp"
    security_groups = [aws_security_group.platform.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "main_alb" {
  vpc_id = var.ecs_vpc_id
  name   = "${var.environment}-alb"

  ingress {
    to_port     = 80
    from_port   = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    to_port     = 443
    from_port   = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "rds" {
  vpc_id = var.ecs_vpc_id
  name   = "${var.environment}-rds"

  ingress {
    to_port   = 5432
    from_port = 5432
    protocol  = "tcp"
    security_groups = [
      aws_security_group.supertokens_ecs.id,
      aws_security_group.platform.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "platform" {
  vpc_id = var.ecs_vpc_id
  name   = "${var.environment}-plaform"

  ingress {
    protocol        = "tcp"
    from_port       = 8000
    to_port         = 8000
    security_groups = [aws_security_group.main_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
