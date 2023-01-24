data "aws_iam_policy_document" "ecs_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }

    sid    = "1"
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    sid    = "1"
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "ssm_secret_access" {
  count = var.attach_ssm_secret_access_policy ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
    ]

    resources = var.ssm_secret_arns
  }
}

data "aws_iam_policy_document" "s3_bucket_access" {
  count = var.attach_s3_access_policy ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]

    resources = var.allowed_s3_buckets_arns
  }
}

data "aws_iam_policy_document" "ecs_ssm" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ssm" {
  count = var.attach_ssm_secret_access_policy ? 1 : 0

  name   = "${var.name}-secret-policy-${var.environment}"
  role   = aws_iam_role.main.id
  policy = data.aws_iam_policy_document.ssm_secret_access[0].json
}

resource "aws_iam_role_policy" "s3" {
  count = var.attach_s3_access_policy ? 1 : 0

  name   = "${var.name}-s3-policy-${var.environment}"
  role   = aws_iam_role.main.id
  policy = data.aws_iam_policy_document.s3_bucket_access[0].json
}

resource "aws_iam_role" "main" {
  assume_role_policy = var.role_type == "ecs" ? data.aws_iam_policy_document.ecs_assume_policy.json : var.role_type == "lamda" ? data.aws_iam_policy_document.lambda.json : ""
  name               = "${var.name}-role-${var.environment}"
}

resource "aws_iam_role_policy_attachment" "ecs_ssm" {
  count = var.attach_ecs_debug_policy ? 1 : 0

  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  count = var.attach_ecs_task_policy ? 1 : 0

  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
