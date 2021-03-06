variable "environment" {
  description = "Policies applied to a specific environment user"
  type        = string
}

variable "iam_user_name" {
  description = "Name of the IAM user"
  type        = string
}

variable "terraform_user_access_backend_list_policies" {
  description = "List of CUSTOM policies to attach to the user"
  type = list(object({
    name        = string
    path        = string
    description = string
  }))
}

variable "aws_managed_policies_list" {
  description = "List of AWS Managed policies to attach to user"
  type        = list(string)
}

variable "tf_user_cluster_policies_mgmt" {
  description = "List of values for cluster policies"
  type        = list(string)
}
