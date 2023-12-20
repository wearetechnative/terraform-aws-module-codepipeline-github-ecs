# locals {
#   codestar_enabled = module.this.enabled && var.codestar_connection_arn != "" && var.codestar_connection_arn != null
# }

data "aws_caller_identity" "this_session" {
}

data "aws_region" "codepipeline" {
}

locals {
  account_id                  = data.aws_caller_identity.this_session.account_id
  codepipeline_resources_name = "codepipeline-${var.pipeline_name}"
}

data "aws_iam_policy_document" "codepipeline_role" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com", "codebuild.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "codepipeline" {
  name               = "${local.codepipeline_resources_name}-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_role.json
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    sid = ""

    actions = [
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*",
      "iam:PassRole",
      "codebuild:*",
      "logs:*",
      "ecr:*",
      "ssm:GetParameters"
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "codepipeline" {
  name   = "${local.codepipeline_resources_name}-codepipeline-policy"
  policy = data.aws_iam_policy_document.codepipeline.json
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = aws_iam_role.codepipeline.id
  policy_arn = aws_iam_policy.codepipeline.arn
}

data "aws_iam_policy_document" "codepipeline_s3" {

  statement {
    sid = ""

    actions = [
      "s3:*"
    ]

    resources = [
      var.codepipeline_s3_arn,
      "${var.codepipeline_s3_arn}/*"
    ]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "codepipeline_s3" {
  name = "${local.codepipeline_resources_name}-codepipeline_s3-policy"

  policy = data.aws_iam_policy_document.codepipeline_s3.json
}


resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.codepipeline.id
  policy_arn = aws_iam_policy.codepipeline_s3.arn
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    sid = ""

    actions = [
      "codebuild:*",
      "logs:*",
      "cloudwatch:*",
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "codebuild" {
  # name   = module.codebuild_label.id
  name   = "${local.codepipeline_resources_name}-codebuild-policy"
  policy = data.aws_iam_policy_document.codebuild.json
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codepipeline.id
  policy_arn = aws_iam_policy.codebuild.arn
}

data "aws_iam_policy_document" "codestar" {
  statement {
    sid = ""

    actions = [
      "codestar-connections:UseConnection"
    ]

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "codestar-connections:FullRepositoryId"
      values   = ["${var.github_repo_owner}/${var.github_repo_name}"]
    }

    resources = [var.codestar_connection_arn]
    effect    = "Allow"

  }
}

resource "aws_iam_policy" "codestar" {
  name   = "${local.codepipeline_resources_name}-codestar-policy"
  policy = data.aws_iam_policy_document.codestar.json
}

resource "aws_iam_role_policy_attachment" "codestar" {
  role       = aws_iam_role.codepipeline.id
  policy_arn = aws_iam_policy.codestar.arn
}
