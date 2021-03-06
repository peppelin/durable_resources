variable "environment" {
  description = "Environments that we want to deploy"
  type        = string
}

variable "elasticache_setting" {
  description = "List for the Elastic Cache Redis based engine instance setting"
  type = object({
    engine          = string
    node_type       = string
    num_cache_nodes = number
    port            = number
    engine_version  = string
    family          = string
  })
}

/*
variable "elasticache_subnets" {
  description = "Subnets for Elasticache"
  type = string
}

variable "elasticache_sg_ids" {
  description = "Security groups ids for Elasticache"
  type = list(string)
}
*/