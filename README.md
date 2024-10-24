
# Terraform AWS Module CodePipeline Github ECS ![](https://img.shields.io/github/workflow/actions/status/wearetechnative/terraform-aws-module-codepipeline-github-ecs/tflint.yaml?style=plastic)

<!-- SHIELDS -->

This module implements ...

[![](we-are-technative.png)](https://www.technative.nl)

## How does it work

### First use after you clone this repository or when .pre-commit-config.yaml is updated

Run `pre-commit install` to install any guardrails implemented using pre-commit.

See [pre-commit installation](https://pre-commit.com/#install) on how to install pre-commit.

...

## Usage

To use this module ...

```hcl
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


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.codepipeline_project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_codebuild_project.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codepipeline.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_iam_policy.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.codepipeline_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.codestar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.codestar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.this_session](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codepipeline_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codepipeline_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codestar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_buildspec"></a> [buildspec](#input\_buildspec) | Name of the file where buildspecs are defined | `string` | `"buildspecs/buildspec.yml"` | no |
| <a name="input_codepipeline-cache_s3_arn"></a> [codepipeline-cache\_s3\_arn](#input\_codepipeline-cache\_s3\_arn) | n/a | `string` | n/a | yes |
| <a name="input_codepipeline-cache_s3_bucket"></a> [codepipeline-cache\_s3\_bucket](#input\_codepipeline-cache\_s3\_bucket) | n/a | `string` | n/a | yes |
| <a name="input_codepipeline_s3_arn"></a> [codepipeline\_s3\_arn](#input\_codepipeline\_s3\_arn) | n/a | `string` | n/a | yes |
| <a name="input_codepipeline_s3_bucket"></a> [codepipeline\_s3\_bucket](#input\_codepipeline\_s3\_bucket) | n/a | `string` | n/a | yes |
| <a name="input_codestar_connection_arn"></a> [codestar\_connection\_arn](#input\_codestar\_connection\_arn) | n/a | `string` | n/a | yes |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name of the ECS cluster to deploy to | `any` | n/a | yes |
| <a name="input_github_branch"></a> [github\_branch](#input\_github\_branch) | Name of the Github branch | `string` | n/a | yes |
| <a name="input_github_repo_name"></a> [github\_repo\_name](#input\_github\_repo\_name) | n/a | `string` | n/a | yes |
| <a name="input_github_repo_owner"></a> [github\_repo\_owner](#input\_github\_repo\_owner) | n/a | `string` | n/a | yes |
| <a name="input_pipeline_name"></a> [pipeline\_name](#input\_pipeline\_name) | n/a | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | AWS Security Group | `list(string)` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service/application in the ECS cluster | `any` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Account subnets | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Account VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | n/a |
<!-- END_TF_DOCS -->
