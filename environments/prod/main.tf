/* 
 * The file in the Dev folder of this project, allow you to create durable resources for Dev env
 *
 * Dev and Prod env create different resources.
 *
 * If you want to change any of the values for the resources created here,  
 *
 * you need to edit dev.tfvars
 *
 * This is the list of durable resources created for **Prod environment**
 *
 * - Terraform users
 * - Cluster role 
 * - Worker node role
 * - Cluster Group management users
 * - Django apps IAM accounts
 * - S3 public and private bucket to be used by IAM accounts
 * - Prod Postgres DB
 * - VPC where setup prod db 
 * - VPC peering between vpcs
 * 
*/

terraform {
  backend "s3" {
    bucket         = "terraform-state-durable-prod-env"
    key            = "terraform-state-durable-prod-env/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "tfStateLockingDurableProdEnv"
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

// Create IAM Cluster management group
module "createClusterMgmtGroup" {
  source = "../../modules/iam/createGroups"

  eks_cluster_management_list_policies = var.eks_cluster_management_list_policies
  cluster_users_mgmt                   = var.cluster_users_mgmt
  attach_user_to_group                 = var.attach_user_to_group
}

// Create IAM Django applications users
module "createAppsUsers" {
  source = "../../modules/iam/createUsers/developmentUsers"

  application_users = var.application_users
}

// Create Django public and private buckets
module "createDjangoBuckets" {
  source = "../../modules/S3Buckets/djangoBuckets"

  django_public_buckets  = var.django_public_buckets
  django_private_buckets = var.django_private_buckets
}

// Create User to create CNAMEs records for landing pages
module "createMgmtLandingPageUser" {
  source = "../../modules/iam/createUsers/cnamesMgmtUser"

  user_name_mgmt_landing_page           = var.user_name_mgmt_landing_page
  cnames_landing_pages_mgmt_policy_name = var.cnames_landing_pages_mgmt_policy_name
}

// Create Lambda Role to perform call to Bubble backup GA script
module "createBubbleBackupRole" {
  source = "../../modules/iam/createRoles/lambdaRole"

  environment                      = var.environment
  lambda_role_bubble_backup        = var.lambda_role_bubble_backup
  lambda_role_delete_bubble_backup = var.lambda_role_delete_bubble_backup

}

// Create Lambda function to call Bubble backup script
module "createBubbleBackupLambda" {
  source = "../../modules/lambdaFunctions/bubbleBackup"

  environment                = var.environment
  lambda_role_bubble_backup  = var.lambda_role_bubble_backup
  lambdaFunctionsEnvironmets = var.lambdaFunctionsEnvironmets
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

// Create Lambda function to call Bubble backup deletion script
module "createDeleteBubbleBackupLambda" {
  source = "../../modules/lambdaFunctions/bubbleDeleteOldBackup"

  lambda_role_delete_bubble_backup = var.lambda_role_delete_bubble_backup
}

// Create VPC where to create PROD Postgres
module "createVPC" {
  source = "../../modules/networking/vpc"

  vpc_cidr_block          = var.vpc_cidr_block
  acl_db_rule             = var.acl_db_rule
  db_private_subnets_cidr = var.db_private_subnets_cidr
  sg_db_rule              = var.sg_db_rule
  availability_zones      = var.availability_zones
}

// Create Postgres for Prod 
module "db" {
  source = "../../modules/db/rdsPostgres"

  environment        = var.environment
  availability_zones = var.availability_zones
  db_subnet_ids      = module.createVPC.db_private_subnets_id
  db_sg              = module.createVPC.db_sg
}
