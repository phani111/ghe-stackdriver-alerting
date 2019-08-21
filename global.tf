terraform {
  backend "gcs" {
    bucket = "sap-tools-secrets-dev"
    prefix = "stackdriver-tf-state/dev"
  }
}

variable "branch" {
  default = "dev"
}

variable "gcp_project" {
  default = "sap-pi-ops-tools-dev-github"
}

variable "gcp_region" {
  default = "sap-pi-ops-tools-dev-github"
}

variable "hostname" {
  default = "github-dev.tools.sap"
}

variable "prefix" {
  default = "[TF] "
}

variable "enabled" {
  default = true
}

variable "slack_hook" {}
variable "support_email" {}

provider "google" {
  project = "${var.gcp_project}"
  region  = "${var.gcp_region}"
  version = "~> 2.12.0"
}
