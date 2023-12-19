# Example
```
module "pipeline-technative-prod" {
  source                       = ""
  codepipeline-cache_s3_arn    = "arn:aws:s3:::example-codebuild-cache-bucket"
  codepipeline-cache_s3_bucket = "example-codebuild-cache-bucket"
  codepipeline_s3_arn          =  "arn:aws:s3:::example-codebuild-bucket"
  codepipeline_s3_bucket       = "example-codebuild-cache-bucket"
  pipeline_name                = "example-pipeline"
  buildspec                    = "buildspecs/buildspec-example-pipeline.yml"
  github_repo_owner            = "company-name"
  github_repo_name             = "my-example-repo"
  github_branch                = "main"
  vpc_id                       = "vpc-123456789abcdef01"
  subnet_ids                   = ["subnet-01234567890123456", "subnet-65432109876543210"]
  security_group_ids           = ["sg-01234567890123456"]
  codestar_connection_arn      = "arn:aws:codestar-connections:us-east-1:111111111111:connection/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
  ecs_cluster_name             = "Example-App"
  service_name                 = "Example_ecs_service_app"
}

```