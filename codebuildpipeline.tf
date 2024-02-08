resource "aws_codebuild_project" "default" {
  for_each = {
    for pipeline_name, pipeline_config in var.pipelines : "${var.app_name}-${pipeline_name}" => pipeline_config if pipeline_config.enabled
  }
  name                   = "${each.key}-Project"
  description            = "Codebuild project for ${each.key} - ${each.value.pipeline_name}"
  concurrent_build_limit = "1"
  service_role           = aws_iam_role.codepipeline[each.key].arn
  build_timeout          = 30
  # badge_enabled          = var.badge_enabled
  # source_version         = var.source_version != "" ? var.source_version : null
  # encryption_key         = var.encryption_key

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "S3"
    location = var.codepipeline-cache_s3_bucket

  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    # image                       = "aws/codebuild/standard:7.0"
    # image = "221539347604.dkr.ecr.us-east-2.amazonaws.com/mustad/equinet_rails_dev:latest"
    image = each.value.docker_run_image  #var.docker_run_image
    image_pull_credentials_type = "CODEBUILD"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = "true" # for deployment to docker
    environment_variable {
      name  = "AWS_REGION"
      value = data.aws_region.codepipeline.name
    }
    environment_variable {
      name  = "KEY_NAME"
      value = "aws/ecr"
    }

    environment_variable {
      name  = "APP_ENV"
      value = each.value.environment
    }

    environment_variable {
      name  = "PIPELINE_ENV"
      value = var.app_name   #var.environment
    }

    environment_variable {

      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.this_session.account_id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = each.value.buildspec  #var.buildspec
    # location            = local.github_source_location
    # report_build_status = "true"
    git_clone_depth = 0

    # git_submodules_config {
    #   fetch_submodules = false
    # }
  }

  vpc_config {
    vpc_id             = var.vpc_id     # var.vpc_id
    subnets            = var.subnet_ids  # var.subnet_ids
    security_group_ids = var.security_group_ids #var.security_group_ids
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "codepipeline-${each.key}-Logs"
      status      = "ENABLED"
      stream_name = "codepipeline-${each.key}-Logs"
    }
  }
}

resource "aws_codepipeline" "codepipeline" {
    for_each = {
    for pipeline_name, pipeline_config in var.pipelines : "${var.app_name}-${pipeline_name}" => pipeline_config if pipeline_config.enabled
  }
  name     = each.key
  # role_arn = module.pipeline_serviceroles.role_arn
  role_arn = aws_iam_role.codepipeline[each.key].arn
  pipeline_type = each.value.pipeline_type #var.pipeline_type

  artifact_store {
    # location = data.terraform_remote_state.shared_services.outputs.s3-codepipeline_bucket #module.pipeline_serviceroles.bucket
    location = var.codepipeline-cache_s3_bucket #var.codepipeline_s3_bucket
    type     = "S3"

    # encryption_key {
    #   id   = "aws/s3"
    #   type = "KMS"
    # }
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
        ConnectionArn    = each.value.codestar_connection_arn  #var.codestar_connection_arn
        FullRepositoryId = "${each.value.github_repo_owner}/${each.value.github_repo_name}"
        BranchName       = each.value.github_branch #var.github_branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildOutput"]
      version          = "1"

      configuration = {
        # ProjectName = "${var.pipeline_name}-Project" #"test"
        ProjectName = "${each.value.pipeline_name}-Project"
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
              # ClusterName = var.ecs_cluster_name
              # ServiceName = var.service_name
              ClusterName = "${each.value.ecs_cluster_name}"
              ServiceName = "${each.value.service_name}" #var.service_name
              FileName    = "/tmp/imagedefinitions.json"
            }
        }
  }

}

resource "aws_cloudwatch_log_group" "codepipeline_project" {
    for_each = {
    for pipeline_name, pipeline_config in var.pipelines : "${var.app_name}-${pipeline_name}" => pipeline_config if pipeline_config.enabled
  }
  name = "codepipeline-${each.key}-${each.value.pipeline_name}-Logs"
}