resource "google_logging_project_sink" "ghe_logging_export_babeld_sink" {
  name = "babeld_sink"
  destination = "bigquery.googleapis.com/projects/sap-pi-ops-tools-prod-github/datasets/babeld_all"
  filter = "resource.type = gce_instance AND labels.compute.googleapis.com/resource_name = prod-ghe-instance-europe-west3-a AND logName = projects/sap-pi-ops-tools-prod-github/logs/babeld"
  unique_writer_identity = true
}

resource "google_logging_project_sink" "ghe_logging_export_github_access_sink" {
  name = "github_access_sink"
  destination = "bigquery.googleapis.com/projects/sap-pi-ops-tools-prod-github/datasets/github_access_all"
  filter = "resource.type = gce_instance AND labels.compute.googleapis.com/resource_name = prod-ghe-instance-europe-west3-a AND logName = projects/sap-pi-ops-tools-prod-github/logs/github_access"
  unique_writer_identity = true
}

resource "google_logging_project_sink" "ghe_logging_export_github_alambic_sink" {
  name = "github_alambic_sink"
  destination = "bigquery.googleapis.com/projects/sap-pi-ops-tools-prod-github/datasets/github_alambic_all"
  filter = "resource.type = gce_instance AND labels.compute.googleapis.com/resource_name = prod-ghe-instance-europe-west3-a AND logName = projects/sap-pi-ops-tools-prod-github/logs/github_alambic"
  unique_writer_identity = true
}

resource "google_logging_project_sink" "ghe_logging_export_github_audit_sink" {
  name = "github_audit_sink"
  destination = "bigquery.googleapis.com/projects/sap-pi-ops-tools-prod-github/datasets/github_audit_all"
  filter = "resource.type = gce_instance AND labels.compute.googleapis.com/resource_name = prod-ghe-instance-europe-west3-a AND logName = projects/sap-pi-ops-tools-prod-github/logs/github_audit"
  unique_writer_identity = true
}

resource "google_logging_project_sink" "ghe_logging_export_github_codeload_sink" {
  name = "github_codeload_sink"
  destination = "bigquery.googleapis.com/projects/sap-pi-ops-tools-prod-github/datasets/github_codeload_all"
  filter = "resource.type = gce_instance AND labels.compute.googleapis.com/resource_name = prod-ghe-instance-europe-west3-a AND logName = projects/sap-pi-ops-tools-prod-github/logs/github_codeload"
  unique_writer_identity = true
}

resource "google_logging_project_sink" "ghe_logging_export_github_ernicorn_sink" {
  name = "github_ernicorn_sink"
  destination = "bigquery.googleapis.com/projects/sap-pi-ops-tools-prod-github/datasets/github_ernicorn_all"
  filter = "resource.type = gce_instance AND labels.compute.googleapis.com/resource_name = prod-ghe-instance-europe-west3-a AND logName = projects/sap-pi-ops-tools-prod-github/logs/github_ernicorn"
  unique_writer_identity = true
}

resource "google_logging_project_sink" "ghe_logging_export_github_exceptions_sink" {
  name = "github_exceptions_sink"
  destination = "bigquery.googleapis.com/projects/sap-pi-ops-tools-prod-github/datasets/github_exceptions_all"
  filter = "resource.type = gce_instance AND labels.compute.googleapis.com/resource_name = prod-ghe-instance-europe-west3-a AND logName = projects/sap-pi-ops-tools-prod-github/logs/github_exceptions"
  unique_writer_identity = true
}

resource "google_logging_project_sink" "ghe_logging_export_github_gitauth_sink" {
  name = "github_gitauth_sink"
  destination = "bigquery.googleapis.com/projects/sap-pi-ops-tools-prod-github/datasets/github_gitauth_all"
  filter = "resource.type = gce_instance AND labels.compute.googleapis.com/resource_name = prod-ghe-instance-europe-west3-a AND logName = projects/sap-pi-ops-tools-prod-github/logs/github_gitauth"
  unique_writer_identity = true
}

resource "google_logging_project_sink" "ghe_logging_export_github_mail_sink" {
  name = "github_mail_sink"
  destination = "bigquery.googleapis.com/projects/sap-pi-ops-tools-prod-github/datasets/github_mail_all"
  filter = "resource.type = gce_instance AND labels.compute.googleapis.com/resource_name = prod-ghe-instance-europe-west3-a AND logName = projects/sap-pi-ops-tools-prod-github/logs/github_mail"
  unique_writer_identity = true
}

resource "google_logging_project_sink" "ghe_logging_export_github_production_sink" {
  name = "github_production_sink"
  destination = "bigquery.googleapis.com/projects/sap-pi-ops-tools-prod-github/datasets/github_production_all"
  filter = "resource.type = gce_instance AND labels.compute.googleapis.com/resource_name = prod-ghe-instance-europe-west3-a AND logName = projects/sap-pi-ops-tools-prod-github/logs/github_production"
  unique_writer_identity = true
}

resource "google_logging_project_sink" "ghe_logging_export_github_resqued_sink" {
  name = "github_resqued_sink"
  destination = "bigquery.googleapis.com/projects/sap-pi-ops-tools-prod-github/datasets/github_resqued_all"
  filter = "resource.type = gce_instance AND labels.compute.googleapis.com/resource_name = prod-ghe-instance-europe-west3-a AND logName = projects/sap-pi-ops-tools-prod-github/logs/github_resqued"
  unique_writer_identity = true
}

resource "google_logging_project_sink" "ghe_logging_export_github_timerd_sink" {
  name = "github_timerd_sink"
  destination = "bigquery.googleapis.com/projects/sap-pi-ops-tools-prod-github/datasets/github_timerd_all"
  filter = "resource.type = gce_instance AND labels.compute.googleapis.com/resource_name = prod-ghe-instance-europe-west3-a AND logName = projects/sap-pi-ops-tools-prod-github/logs/github_timerd"
  unique_writer_identity = true
}

resource "google_logging_project_sink" "ghe_logging_export_github_unicorn_sink" {
  name = "github_unicorn_sink"
  destination = "bigquery.googleapis.com/projects/sap-pi-ops-tools-prod-github/datasets/github_unicorn_all"
  filter = "resource.type = gce_instance AND labels.compute.googleapis.com/resource_name = prod-ghe-instance-europe-west3-a AND logName = projects/sap-pi-ops-tools-prod-github/logs/github_unicorn"
  unique_writer_identity = true
}

resource "google_logging_project_sink" "ghe_logging_export_gitmon_sink" {
  name = "gitmon_sink"
  destination = "bigquery.googleapis.com/projects/sap-pi-ops-tools-prod-github/datasets/gitmon_all"
  filter = "resource.type = gce_instance AND labels.compute.googleapis.com/resource_name = prod-ghe-instance-europe-west3-a AND logName = projects/sap-pi-ops-tools-prod-github/logs/gitmon"
  unique_writer_identity = true
}

resource "google_logging_project_sink" "ghe_logging_export_haproxy_sink" {
  name = "haproxy_sink"
  destination = "bigquery.googleapis.com/projects/sap-pi-ops-tools-prod-github/datasets/haproxy_all"
  filter = "resource.type = gce_instance AND labels.compute.googleapis.com/resource_name = prod-ghe-instance-europe-west3-a AND logName = projects/sap-pi-ops-tools-prod-github/logs/haproxy"
  unique_writer_identity = true
}