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