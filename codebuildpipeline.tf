resource "aws_codebuild_project" "default" {
  name                   = "${var.pipeline_name}-Project"
  description            = "Codebuild project for ${var.pipeline_name}"
  concurrent_build_limit = "1"
  service_role           = aws_iam_role.codepipeline.arn
  build_timeout          = 30
  # badge_enabled          = var.badge_enabled
  # source_version         = var.source_version != "" ? var.source_version : null
  # encryption_key         = var.encryption_key

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "S3"
    # modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
    location = var.codepipeline-cache_s3_bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    image_pull_credentials_type = "CODEBUILD"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = "true" # for deployment to docker
    environment_variable {
      name  = "AWS_REGION"
      value = data.aws_region.codepipeline.name
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.this_session.account_id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file(var.buildspec)
    # location            = local.github_source_location
    # report_build_status = "true"
    git_clone_depth = 0

    # git_submodules_config {
    #   fetch_submodules = false
    # }
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "codepipeline-${var.pipeline_name}-Logs"
      status      = "ENABLED"
      stream_name = "codepipeline-${var.pipeline_name}-Logs"
    }
  }
}

resource "aws_codepipeline" "codepipeline" {
  name = var.pipeline_name
  # role_arn = module.pipeline_serviceroles.role_arn
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    # location = data.terraform_remote_state.shared_services.outputs.s3-codepipeline_bucket #module.pipeline_serviceroles.bucket
    location = var.codepipeline_s3_bucket
    type     = "S3"

    encryption_key {
      id = var.codepipeline_s3_kms
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      namespace        = "SourceVariables"

      configuration = {
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = "${var.github_repo_owner}/${var.github_repo_name}"
        BranchName           = var.github_branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  # stage {
  #   name = "Build"

  #   action {
  #     name             = "Build"
  #     category         = "Build"
  #     owner            = "AWS"
  #     provider         = "CodeBuild"
  #     input_artifacts  = ["SourceArtifact"]
  #     output_artifacts = ["BuildOutput"]
  #     version          = "1"

  #     configuration = {
  #       ProjectName = "${var.pipeline_name}-Project" #"test"
  #     }
  #   }
  # }


  dynamic "stage" {
    for_each = var.build_stage

    content {
      name = stage.value.build_stage_name

      action {
        name             = "${stage.value.build_stage_name}"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = ["${stage.value.name}Output"]
        version          = "1"

        configuration = {
          ProjectName = stage.value.project_name
        }
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildOutput"]
      version         = "1"

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.service_name
        FileName    = "/tmp/imagedefinitions.json"

      }
    }
  }
}

resource "aws_cloudwatch_log_group" "codepipeline_project" {
  name = "codepipeline-${var.pipeline_name}-Logs"
}