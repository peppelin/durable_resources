/* 
 * This module is used to deploy ElastiCache instance based on Redis engine with a single instance
 *
 * ElastiCache is used by the Django apps to 
 *
 * A part that Redis based instance, this module also create
 *
 * - cluster parameter group
 * - subnet group needed
 * - cluster user  
 * 
*/

// Create Parameters group for Elasticache cluster
resource "aws_elasticache_parameter_group" "default" {
  name   = "cache-params-${var.environment}-env"
  family = var.elasticache_setting.family
}

// Read db subnets existing
data "aws_subnets" "elaticache_subnets" {
  filter {
    name   = "tag:Name"
    values = ["db-subnet-*-${var.environment}-environment"]
  }
}

// Set the subnet for Redis
resource "aws_elasticache_subnet_group" "redis_subnet" {
  name       = "redis-cache-subnet-${var.environment}-env"
  subnet_ids = flatten([element(data.aws_subnets.elaticache_subnets.ids, 0)])
}



// If auth token is enabled, then redis-cli cannot works
// https://stackoverflow.com/questions/47696004/aws-elasticache-redis-cant-connect-from-laravel-nad-from-redis-cli
// https://www.reddit.com/r/aws/comments/7p04p4/elasticache_encryption_in_transit/dtgferx/
// Create elasticache group 
/*resource "aws_elasticache_replication_group" "elasticache_gorup" {
  replication_group_description = "Elasticache group replication"
  replication_group_id          = "single-node-replication"
  transit_encryption_enabled    = true
  node_type                     = var.elasticache_setting.node_type
  security_group_ids            = var.elasticache_sg_ids
  subnet_group_name             = aws_elasticache_subnet_group.redis_subnet.name
  auth_token                    = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["password"]
} */

// Read redis sg existing
data "aws_security_group" "redis_sg" {
  filter {
    name   = "tag:Name"
    values = ["db-sg-${var.environment}-environment"]
  }
}

// Create ElastiCache cluster based on Redis and on 1 node atm
resource "aws_elasticache_cluster" "elasticache_cluster" {
  cluster_id           = "cluster-${var.environment}-env"
  engine               = var.elasticache_setting.engine
  node_type            = var.elasticache_setting.node_type
  num_cache_nodes      = var.elasticache_setting.num_cache_nodes
  parameter_group_name = aws_elasticache_parameter_group.default.name
  engine_version       = var.elasticache_setting.engine_version
  port                 = var.elasticache_setting.port
  // the next create the instance in the first subnet
  subnet_group_name  = aws_elasticache_subnet_group.redis_subnet.id
  security_group_ids = ["${data.aws_security_group.redis_sg.id}"]
  //replication_group_id = aws_elasticache_replication_group.elasticache_gorup.id
}

// Read secret for prod secrets
data "aws_secretsmanager_secret" "prod_secrets" {
  name = "elasticacheprodenv"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.prod_secrets.id
}

// Create Redis user
resource "aws_elasticache_user" "redis_user" {
  user_id       = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["username"]
  user_name     = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["username"]
  access_string = "on ~app::* +@all"
  engine        = "REDIS"
  passwords     = [jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["password"]]
}
