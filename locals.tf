locals {
  tags = merge(var.tags ,{ tf-module = "${var.env}-alb"} , { env = var.env })
}