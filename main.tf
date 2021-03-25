# Provider設定
provider "aws" {
  region = "ap-northeast-1"
}

variable "app_name" {
  type = string
  default = "sample"
}

variable "azs" {
  type = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c"]
}

module "iam" {
  source = "./iam"
  app_name = var.app_name
}

module "network" {
  source   = "./network"
  app_name = var.app_name
  azs      = var.azs
}

module "elb" {
  source = "./elb"

  app_name = var.app_name

  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}

module "ecs_cluster" {
  source = "./ecs_cluster"
  app_name = var.app_name
}

module "ecs_app" {
  source = "./ecs_app"

  app_name = var.app_name

  cluster_name       = module.ecs_cluster.cluster_name
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  http_listener_arn  = module.elb.http_listener_arn

  iam_role_task_execution_arn = module.iam.iam_role_task_execution_arn
}
