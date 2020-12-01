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