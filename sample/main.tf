# Provider設定
provider "aws" {
  region = "ap-northeast-1"
}

variable "name" {
  type = string
  default = "sample-app"
}

variable "azs" {
  type = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

module "network" {
  source = "./network"
  name   = var.name
  azs    = var.azs
}

module "elb" {
  source = "./elb"

  name = var.name
  vpc_id = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}