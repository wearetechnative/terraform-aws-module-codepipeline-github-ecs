# locals {
#   codestar_enabled = module.this.enabled && var.codestar_connection_arn != "" && var.codestar_connection_arn != null
# }

data "aws_caller_identity" "this_session" {
}

data "aws_region" "codepipeline" {
}

# locals {
#   for_each = {
#     for pipeline_name, pipeline_config in var.pipelines : "${var.app_name}-${pipeline_name}" => pipeline_config if pipeline_config.enabled
#   }
#   account_id                  = data.aws_caller_identity.this_session.account_id
#   codepipeline_resources_name = "codepipeline-${each.value.pipeline_name}"
# }

data "aws_iam_policy_document" "codepipeline_role" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com","codebuild.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "codepipeline" {
  for_each = {
    for pipeline_name, pipeline_config in var.pipelines : "${var.app_name}-${pipeline_name}" => pipeline_config if pipeline_config.enabled
  }
  # name               = "${local.codepipeline_resources_name}-${var.environment}-role"
  name               = "codepipeline-${each.key}-${each.value.environment}-role"
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
  for_each = {
    for pipeline_name, pipeline_config in var.pipelines : "${var.app_name}-${pipeline_name}" => pipeline_config if pipeline_config.enabled
  }

  name   = "codepipeline-${each.key}-${each.value.pipeline_name}-${each.value.environment}-codepipeline-policy"
  policy = data.aws_iam_policy_document.codepipeline.json
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
   for_each = {
    for pipeline_name, pipeline_config in var.pipelines : "${var.app_name}-${pipeline_name}" => pipeline_config if pipeline_config.enabled
  }
  role       = aws_iam_role.codepipeline[each.key].id
  policy_arn = aws_iam_policy.codepipeline[each.key].arn
}

data "aws_iam_policy_document" "codepipeline_s3" {
  for_each = {
    for pipeline_name, pipeline_config in var.pipelines : "${var.app_name}-${pipeline_name}" => pipeline_config if pipeline_config.enabled
  }

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
  for_each = {
    for pipeline_name, pipeline_config in var.pipelines : "${var.app_name}-${pipeline_name}" => pipeline_config if pipeline_config.enabled
  }
  name = "codepipeline-${each.key}-${each.value.pipeline_name}-${each.value.environment}-codepipeline_s3-policy"

  policy = data.aws_iam_policy_document.codepipeline_s3[each.key].json
}


resource "aws_iam_role_policy_attachment" "s3" {
   for_each = {
    for pipeline_name, pipeline_config in var.pipelines : "${var.app_name}-${pipeline_name}" => pipeline_config if pipeline_config.enabled
  }
  role       = aws_iam_role.codepipeline[each.key].id
  policy_arn = aws_iam_policy.codepipeline_s3[each.key].arn
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    sid = ""

    actions = [
      "codebuild:*",
      "logs:*",
      "cloudwatch:*",
      "ecr:*"
    ]

    resources = ["*"]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "codebuild" {
  for_each = {
    for pipeline_name, pipeline_config in var.pipelines : "${var.app_name}-${pipeline_name}" => pipeline_config if pipeline_config.enabled
  }
  # name   = module.codebuild_label.id
  name   = "codepipeline-${each.key}-${each.value.pipeline_name}-${each.value.environment}-codebuild-policy"
  policy = data.aws_iam_policy_document.codebuild.json
}

resource "aws_iam_role_policy_attachment" "codebuild" {
   for_each = {
    for pipeline_name, pipeline_config in var.pipelines : "${var.app_name}-${pipeline_name}" => pipeline_config if pipeline_config.enabled
  }
  role       = aws_iam_role.codepipeline[each.key].id
  policy_arn = aws_iam_policy.codebuild[each.key].arn
}

data "aws_iam_policy_document" "codestar" {
  for_each = {
    for pipeline_name, pipeline_config in var.pipelines : "${var.app_name}-${pipeline_name}" => pipeline_config if pipeline_config.enabled
  }
  statement {
    sid = ""

    actions = [
      "codestar-connections:UseConnection"
    ]

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "codestar-connections:FullRepositoryId"
      # values   = ["${var.github_repo_owner}/${var.github_repo_name}"]
      values = ["${each.value.github_repo_owner}/${each.value.github_repo_name}"]
    }

    resources = [each.value.codestar_connection_arn]
    effect    = "Allow"

  }
}

resource "aws_iam_policy" "codestar" {
  for_each = {
    for pipeline_name, pipeline_config in var.pipelines : "${var.app_name}-${pipeline_name}" => pipeline_config if pipeline_config.enabled
  }
  name   = "codepipeline-${each.key}-${each.value.pipeline_name}-${each.value.environment}-codestar-policy"
  policy = data.aws_iam_policy_document.codestar[each.key].json
}

resource "aws_iam_role_policy_attachment" "codestar" {
  for_each = {
    for pipeline_name, pipeline_config in var.pipelines : "${var.app_name}-${pipeline_name}" => pipeline_config if pipeline_config.enabled
  }
  role       = aws_iam_role.codepipeline[each.key].id
  policy_arn = aws_iam_policy.codestar[each.key].arn
}
