variable "environment" {
  description = "Environment to deploy"
  type        = string
}

variable "alb_ingress_controller_role_env" {
  description = "List of ALB ingress controller roles for environment"
  type        = list(string)
}

variable "alb_ingress_controller" {
  type = object({
    name        = string
    path        = string
    description = string
  })
}

variable "ec2_full_access" {
  type = object({
    name        = string
    path        = string
    description = string
  })
}

variable "iam_limited_access" {
  type = object({
    name        = string
    path        = string
    description = string
  })
}

variable "eks_all_access" {
  type = object({
    name        = string
    path        = string
    description = string
  })
}

variable "iam_customer_eks_policies" {
  description = "AWS IAM customer policies for EKS"
  type        = list(string)
}

variable "iam_aws_eks_policies" {
  description = "AWS IAM managed policies for EKS"
  type        = list(string)
}

variable "aim_aws_worker_node_policies" {
  description = "AWS IAM managed policies for worker node"
  type        = list(string)
}

variable "worker_node_role" {
  description = "Name of the worker node role"
  type        = string
}

variable "customer_policy_worker_node" {
  description = "AWS IAM customer policies for worker node role"
  type        = list(string)
}

variable "worker_node_manage_ebs_volume" {
  description = "Worker node policy in order to access to the volume"
  type = object({
    name        = string
    path        = string
    description = string
  })
}
