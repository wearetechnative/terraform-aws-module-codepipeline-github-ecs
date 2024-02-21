resource "aws_codebuild_project" "default" {
  name                   = "${var.pipeline_name}-Project"
  description            = "Codebuild project for ${var.pipeline_name}"
  concurrent_build_limit = "1"
  service_role           = aws_iam_role.codepipeline.arn
  build_timeout          = 30

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = var.codepipeline-cache_s3_bucket
  }

  environment {
    compute_type = "BUILD_GENERAL1_LARGE"
    image                       = var.docker_run_image
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
      value = var.environment
    }


    environment_variable {
      name  = "PIPELINE_ENV"
      value = var.environment
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.this_session.account_id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec
    git_clone_depth = 0
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
  name          = var.pipeline_name
  role_arn      = aws_iam_role.codepipeline.arn
  pipeline_type = var.pipeline_type

  artifact_store {
    location = var.codepipeline_s3_bucket
    type     = "S3"
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
        ProjectName = "${var.pipeline_name}-Project" #"test"
      }

    }
  }

  dynamic "stage" {
    # Create resources for each deployment specified in var.deploy_to_ecs
    # if var.deploy_to_ecs is not null, otherwise, no resources are created.
    for_each = var.deploy_to_ecs != null ? keys(var.deploy_to_ecs.deployments) : []
    content {
      name = "Deploy-${stage.value}"

      action {
        name            = "Deploy"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "ECS"
        input_artifacts = ["BuildOutput"]
        version         = "1"

        configuration = {
          ClusterName = var.deploy_to_ecs.deployments[stage.value].ClusterName
          ServiceName = var.deploy_to_ecs.deployments[stage.value].ServiceName
          FileName    = var.deploy_to_ecs.deployments[stage.value].FileName
        }
      }
    }
  }


}

resource "aws_cloudwatch_log_group" "codepipeline_project" {
  name = "codepipeline-${var.pipeline_name}-Logs"
}
