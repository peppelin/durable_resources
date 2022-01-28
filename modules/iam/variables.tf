variable "environment" {
  type = string
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