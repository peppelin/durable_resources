/* 
 * The file in the Dev folder of this project, allow you to create durable resources for Dev env
 *
 * Dev and Prod env create different resources.
 *
 * If you want to change any of the values for the resources created here,  
 *
 * you need to edit dev.tfvars
 *
 * This is the list of durable resources created for **Dev environment**
 *
 * - Terraform users
 * - Cluster role 
 * - Worker node role
 * - Grafana user and role
*/

terraform {
  backend "s3" {
    bucket         = "terraform-state-durable-dev-env"
    key            = "terraform-state-durable-dev-env/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "tfStateLockingDurableDevEnv"
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Environment   = var.environment
      Type_Resource = var.type_resource
    }
  }
}

// Create IAM terraform user
module "createUsers" {
  source = "../../modules/iam/createUsers/terraformUsers"

  environment                                 = var.environment
  iam_user_name                               = var.iam_user_name
  terraform_user_access_backend_list_policies = var.terraform_user_access_backend_list_policies
  aws_managed_policies_list                   = var.aws_managed_policies_list
  tf_user_cluster_policies_mgmt               = var.tf_user_cluster_policies_mgmt
}

// Create cluster roles
module "createClusterRoles" {
  source = "../../modules/iam/createRoles/eksClusterRole"

  environment                     = var.environment
  iam_aws_eks_policies            = var.iam_aws_eks_policies
  iam_customer_eks_policies       = var.iam_customer_eks_policies
  alb_ingress_controller_role_env = var.alb_ingress_controller_role_env
  eks_cluster_role_policies       = var.eks_cluster_role_policies
}

// Create worker node role
module "createWorkerNodeRole" {
  source = "../../modules/iam/createRoles/eksWorkerNodeRole"

  environment                  = var.environment
  worker_node_role             = var.worker_node_role
  iam_aws_worker_node_policies = var.iam_aws_worker_node_policies
  customer_policy_worker_node  = var.customer_policy_worker_node
  manage_hosted_zone_policy    = var.manage_hosted_zone_policy
}

// Create Grafana role 
module "createGrafanaRole" {
  source = "../../modules/iam/createRoles/grafanaRoleCloudWatch"

  environment              = var.environment
  read_only_billing_policy = var.read_only_billing_policy
  grafana_role             = var.grafana_role
}

// Create Grafana User
module "createGrafanaUser" {
  source = "../../modules/iam/createUsers/grafanaUser"

  environment              = var.environment
  grafana_user             = var.grafana_user
  read_only_billing_policy = var.read_only_billing_policy
}

// Create GitLab S3 bucket
module "createBuckets" {
  source = "../../modules/S3Buckets/gitlabRunnerLogsBuckets"

  environment        = var.environment
  gitlab_bucket_name = var.gitlab_bucket_name
}

// Create GitLab User 
module "createGitLabUser" {
  source = "../../modules/iam/createUsers/gitlabRunnerUsers"

  environment        = var.environment
  gitlab_user        = var.gitlab_user
  gitlab_bucket_name = var.gitlab_bucket_name
}

// Create Lens User
module "createLensUser" {
  source = "../../modules/iam/createUsers/lensUsers"

  environment        = var.environment
}

// Create Networking schema 
/*
module "networking" {
  source = "../../modules/networking/vpc/"

  environment                    = var.environment
  vpc_cidr_block                 = var.vpc_cidr_block
  public_subnets_cidr            = var.public_subnets_cidr
  private_subnets_cidr           = var.private_subnets_cidr
  availability_zones             = var.availability_zones
  alb_ingress_rule               = var.alb_ingress_rule
  eks_ingress_rule               = var.eks_ingress_rule
  bastion_ingress_rule           = var.bastion_ingress_rule
  private_instances_ingress_rule = var.private_instances_ingress_rule
  acl_public_subnet_rule         = var.acl_public_subnet_rule
  acl_private_subnet_rule        = var.acl_private_subnet_rule
  acl_db_rule                    = var.acl_db_rule
  sg_db_rule                     = var.sg_db_rule
  db_private_subnets_cidr        = var.db_private_subnets_cidr
  sg_gitlab_runners_rules        = var.sg_gitlab_runners_rules
}

// Create GitLab Runners
module "gitlabRunnersInfraAws" {
  depends_on = [module.networking]
  source     = "../../modules/gitlab/setupRunners"

  environment                           = var.environment
  registration_token_infra              = var.registration_token_infra
  aux_token                             = var.registration_token_infra
  registration_token                    = var.registration_token_infra
  registration_token_cluster_mgmt_chart = ""
  gitlab_bucket_name                    = var.gitlab_bucket_name
  aws_region                            = var.aws_region
  ami_owners                            = var.ami_owners
  metrics_autoscaling                   = var.metrics_autoscaling
  docker_machine_paramenters            = var.docker_machine_paramenters
  runner_parameters                     = var.runner_parameters
  gitlab_project_list                   = var.gitlab_project_list
  gitlab_project                        = var.gitlab_project_list.infra
}

module "gitlabRunnersClusterMgmgChart" {
  depends_on = [module.networking]
  source     = "../../modules/gitlab/setupRunners"

  environment                           = var.environment
  registration_token_cluster_mgmt_chart = var.registration_token_cluster_mgmt_chart
  aux_token                             = var.registration_token_cluster_mgmt_chart
  registration_token                    = var.registration_token_cluster_mgmt_chart
  registration_token_infra              = ""
  gitlab_bucket_name                    = var.gitlab_bucket_name
  aws_region                            = var.aws_region
  ami_owners                            = var.ami_owners
  metrics_autoscaling                   = var.metrics_autoscaling
  docker_machine_paramenters            = var.docker_machine_paramenters
  runner_parameters                     = var.runner_parameters
  gitlab_project_list                   = var.gitlab_project_list
  gitlab_project                        = var.gitlab_project_list.cluster_mgmt_chart
}*/
