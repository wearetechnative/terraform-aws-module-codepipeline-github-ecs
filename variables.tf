variable "app_name" {
  type = string
}

variable "pipelines" {
  type = map(object({
    enabled                      = bool
    codepipeline_s3_kms          = string
    # codepipeline-cache_s3_bucket = string
    # codepipeline_s3_arn          = string
    # codepipeline_s3_bucket       = string
    # vpc_id                       = string
    # subnet_ids                   = string
    # security_group_ids           = string
    codestar_connection_arn      = string
    pipeline_type                = string
    pipeline_name                = string
    github_repo_name             = string
    github_branch                = string
    github_repo_owner            = string
    environment                  = string
    buildspec                    = string
    ecs_cluster_name             = string
    service_name                 = string
    deploy_to_ecs                = bool
    account                      = string
    docker_run_image             = string
  }))
}

variable "var_c" {
  type = string
}


# github_repo_owner            = each.value.github_repo_owner
#   codepipeline_s3_kms          = "alias/aws/s3"
#   codepipeline-cache_s3_arn    = data.terraform_remote_state.shared_services.outputs.s3-codepipeline-cache_arn
#   codepipeline-cache_s3_bucket = data.terraform_remote_state.shared_services.outputs.s3-codepipeline-cache_bucket
#   codepipeline_s3_arn          = data.terraform_remote_state.shared_services.outputs.s3-codepipeline_arn
#   codepipeline_s3_bucket       = data.terraform_remote_state.shared_services.outputs.s3-codepipeline_bucket
#   vpc_id                       = data.aws_vpc.vpc.id
#   subnet_ids                   = [data.aws_subnet.privsubnet1.id, data.aws_subnet.privsubnet2.id]
#   security_group_ids           = [aws_security_group.codepipeline.id]
#   codestar_connection_arn      = each.value.codestar_connection_arn
#   pipeline_type                = "V2"



#   ## APP Environments dependent variables
#   for_each         = var.app_environments
#   pipeline_name    = "${each.key}-equinet-be-pipeline"
#   github_repo_name = each.value.github_repo_name
#   github_branch    = each.value.github_branch
#   environment      = each.key
#   buildspec        = contains(local.equinet-be_buildspec_local_environments, each.key) ? file("buildspecs/buildspec-${each.key}-${local.equinet-be_buildspec_filename_suffix}") : "buildspecs/buildspec-${each.key}-${local.equinet-be_buildspec_filename_suffix}"
#   ecs_cluster_name = "Equinet-Backend-${each.key}"
#   service_name     = "equinet_app_${each.key}"
#   deploy_to_ecs    = contains(local.equinet-be_no_deploy_to_ecs_environments, each.key) ? "false" : "true"
#   account          = var.account
#   docker_run_image = each.value.docker_run_image

  variable "codepipeline-cache_s3_arn" {
    type = string
  }
  variable "codepipeline-cache_s3_bucket" {
    type = string
  }
  variable "codepipeline_s3_arn" {
    type = string
  }
  variable "codepipeline_s3_bucket" {
    type = string
  }
  variable "security_group_ids" {
    type = list(string)
  }
  variable "subnet_ids" {
    type = list(string)
  }

  variable "vpc_id" {
    type = string
  }
