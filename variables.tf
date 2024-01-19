variable "pipeline_name" {
  type = string
}

variable "environment" {
}

variable "codepipeline_s3_bucket" {
  type = string
}

variable "codepipeline_s3_arn" {
  type = string
}

variable "codepipeline_s3_kms" {
  type = string
}

variable "codepipeline-cache_s3_bucket" {
  type = string
}

variable "codepipeline-cache_s3_arn" {
  type = string
}

variable "github_repo_owner" {
  type = string
}

variable "github_repo_name" {
  type = string
}

variable "codestar_connection_arn" {
  type = string
}

variable "buildspec" {
  description = "Name of the file where buildspecs are defined"
  type        = string
  default     = "buildspecs/buildspec.yml"
}

variable "vpc_id" {
  description = "Account VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Account subnets"
  type        = list(string)
}

variable "security_group_ids" {
  description = "AWS Security Group"
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster to deploy to"
}

variable "service_name" {
  description = "Name of the service/application in the ECS cluster"
}
variable "github_branch" {
  description = "Name of the Github branch"
  type        = string
}

variable "deploy_to_ecs" {
  type        = bool
  description = "Enable/disable the build stage"
  default     = true
}

variable "push_to_ecr" {
  type        = bool
  description = "Push code to ECR"
  default     = true
}

variable "account" {
  type        = string
  description = "AWS account number"
}

variable "docker_run_image" {
}

variable "pipeline_type" {
  type=string
  description = "pipeline_type, V1 or V2"
  default = "V1"
}


# variable "bucket_kms_master_key_id" {
#   type = string
# }

# variable "pipeline_name" {
#   description = "Name of the pipeline"
#   type        = string
# }

# variable "codepipeline_s3_arn" {
# }

# variable "codepipeline-cache_s3_bucket=var.codepipelince-cache-s3_bucket" {
# }

# variable "codepipeline-cache_s3_arn=var.codepipeline-cache_s3_arn" {
# }
