terraform {
  backend "gcs" {}
}

variable "branch" {}

variable "gcp_project" {}

variable "slack_hook" {}
variable "slack_channel" {}
variable "support_email" {}

locals {
  hostname   = "${var.branch == "prod" ? "github.tools.sap" : "github-${var.branch}.tools.sap"}"
  prefix     = "[TF] "
  enabled    = false
  gcp_region = "europe-west3"
}

provider "google" {
  project = "${var.gcp_project}"
  region  = "${local.gcp_region}"
  version = "~> 2.12.0"
}
