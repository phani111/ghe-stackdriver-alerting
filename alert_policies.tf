resource "google_logging_metric" "ghe_instance_a_logging_metric" {
  name   = "ghe-a-log-counter"
  filter = "resource.type=\"gce_instance\"\nlabels.\"compute.googleapis.com/resource_name\"=\"dev-ghe-instance-europe-west3-a\""

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_logging_metric" "ghe_instance_b_logging_metric" {
  name   = "ghe-b-log-counter"
  filter = "resource.type=\"gce_instance\"\nlabels.\"compute.googleapis.com/resource_name\"=\"dev-ghe-instance-europe-west3-b\""

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "ghe_instance_logging" {
  display_name = "${var.prefix}GHE Instance Logging"
  combiner     = "OR"
  enabled      = "${var.enabled}"

  conditions = [
    {
      display_name = "${var.prefix}logging/user/${google_logging_metric.ghe_instance_a_logging_metric.name} [SUM]"

      condition_threshold {
        filter          = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.ghe_instance_a_logging_metric.name}\" resource.type=\"gce_instance\" metadata.user_labels.\"env\"=\"${var.branch}\""
        duration        = "900s"
        comparison      = "COMPARISON_LT"
        threshold_value = 1

        aggregations {
          alignment_period     = "60s"
          per_series_aligner   = "ALIGN_MEAN"
          cross_series_reducer = "REDUCE_SUM"
        }

        trigger {
          count = 1
        }
      }
    },
    {
      display_name = "${var.prefix}logging/user/${google_logging_metric.ghe_instance_b_logging_metric.name} [SUM]"

      condition_threshold {
        filter          = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.ghe_instance_b_logging_metric.name}\" resource.type=\"gce_instance\" metadata.user_labels.\"env\"=\"${var.branch}\""
        duration        = "900s"
        comparison      = "COMPARISON_LT"
        threshold_value = 1

        aggregations {
          alignment_period     = "60s"
          per_series_aligner   = "ALIGN_MEAN"
          cross_series_reducer = "REDUCE_SUM"
        }

        trigger {
          count = 1
        }
      }
    },
  ]

  documentation {
    content = <<EOF
GitHub Primary or Replica Logs are not arriving in Stackdriver.

Check `sudo systemctl status google-fluentd`
Restart `sudo service google-fluentd restart`

and

Stackdriver / Prometheus Exporter `tail -f /var/log/stackdriver-prometheus-exporter/exporter.log` or check crontab `sudo -s crontab -e`
    EOF
  }

  notification_channels = [
    "${google_monitoring_notification_channel.ghe-email.name}",
    "${google_monitoring_notification_channel.ghe-ops-slack.name}",
  ]
}

resource "google_monitoring_alert_policy" "vm_instance_down" {
  display_name = "${var.prefix}VM Instance Down"
  combiner     = "OR"
  enabled      = "${var.enabled}"

  conditions = [{
    display_name = "${var.prefix}Any VM Instance Down"

    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/uptime\" resource.type=\"gce_instance\" metadata.user_labels.\"env\"=\"${var.branch}\" metric.label.\"instance_name\"!=monitoring.regex.full_match(\"bastion\")"
      duration        = "120s"
      comparison      = "COMPARISON_LT"
      threshold_value = 1

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }

      trigger {
        count = 1
      }
    }
  }]

  documentation {
    content = <<EOF
Instance Down. 
Please restart Instance.
    EOF
  }

  notification_channels = [
    "${google_monitoring_notification_channel.ghe-email.name}",
    "${google_monitoring_notification_channel.ghe-ops-slack.name}",
  ]
}

resource "google_monitoring_alert_policy" "vm_disk_utilization" {
  display_name = "${var.prefix}VM Disk Utilization"
  combiner     = "OR"
  enabled      = "${var.enabled}"

  conditions = [{
    display_name = "${var.prefix}Any Disk over 80% utilization"

    condition_threshold {
      filter          = "metric.type=\"agent.googleapis.com/disk/percent_used\" resource.type=\"gce_instance\" metric.label.\"state\"=\"used\" metadata.user_labels.\"env\"=\"${var.branch}\" metric.label.\"device\"=\"sda1\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 80

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }]

  documentation {
    content = <<EOF
VM Disk utilization is over 80%. Check logrotation and/or increase disk size.
    EOF
  }

  notification_channels = [
    "${google_monitoring_notification_channel.ghe-email.name}",
    "${google_monitoring_notification_channel.ghe-ops-slack.name}",
  ]
}

resource "google_monitoring_uptime_check_config" "ghe_http_uptime" {
  display_name = "${var.prefix}GitHub HTTPS Uptime Check"
  timeout      = "10s"
  period       = "300s"

  http_check {
    path    = "/status"
    port    = "443"
    use_ssl = true
  }

  monitored_resource {
    type = "uptime_url"

    labels = {
      project_id = "${var.gcp_project}"
      host       = "${var.hostname}"
    }
  }
}

resource "google_monitoring_alert_policy" "ghe_https_status" {
  display_name = "${var.prefix}GitHub HTTPS Status Check"
  combiner     = "OR"
  enabled      = "${var.enabled}"

  conditions {
    display_name = "${var.prefix}Generic HTTPS check on github.tools.sap at /status"

    condition_threshold {
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" resource.type=\"uptime_url\" metric.label.\"check_id\"=\"${google_monitoring_uptime_check_config.ghe_http_uptime.uptime_check_id}\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1

      aggregations {
        alignment_period     = "1200s"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        group_by_fields      = ["resource.*"]
      }

      trigger {
        count = 1
      }
    }
  }

  documentation {
    content = <<EOF
GitHub not healthy.
    EOF
  }

  notification_channels = [
    "${google_monitoring_notification_channel.ghe-email.name}",
    "${google_monitoring_notification_channel.ghe-ops-slack.name}",
  ]
}

resource "google_monitoring_alert_policy" "ghe_backup_absent" {
  display_name = "${var.prefix}GHE Backup Absent"
  combiner     = "OR"
  enabled      = "${var.enabled}"

  conditions = [{
    display_name = "${var.prefix}Backup Create Job Completion Time"

    condition_threshold {
      filter          = "metric.type=\"custom.googleapis.com/github/backup_create_job_completion_time\" resource.type=\"gce_instance\" metadata.user_labels.\"env\"=\"${var.branch}\""
      duration        = "84600s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  },
    {
      display_name = "${var.prefix}Backup Upload Job Completion Time"

      condition_threshold {
        filter          = "metric.type=\"custom.googleapis.com/github/backup_upload_job_completion_time\" resource.type=\"gce_instance\" metadata.user_labels.\"env\"=\"${var.branch}\""
        duration        = "84600s"
        comparison      = "COMPARISON_GT"
        threshold_value = 1

        aggregations {
          alignment_period   = "60s"
          per_series_aligner = "ALIGN_MEAN"
        }

        trigger {
          count = 1
        }
      }
    },
  ]

  documentation {
    content = <<EOF
GHE Backup failed.
    EOF
  }

  notification_channels = [
    "${google_monitoring_notification_channel.ghe-email.name}",
    "${google_monitoring_notification_channel.ghe-ops-slack.name}",
  ]
}

resource "google_monitoring_alert_policy" "ghe_hookshot_queue" {
  display_name = "${var.prefix}GHE Hookshot Queue"
  combiner     = "OR"
  enabled      = "${var.enabled}"

  conditions = {
    display_name = "${var.prefix}GHE Hookshot Queue is filling"

    condition_threshold {
      filter          = "metric.type=\"custom.googleapis.com/github/listener_gauge\" resource.type=\"gce_instance\" metric.label.\"listener\"=\"hookshot\" metric.label.\"type\"=\"queued\" metadata.user_labels.\"env\"=\"${var.branch}\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 10

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  documentation {
    content = <<EOF
GHE Hookshot Queue is filling, WebHooks are not executed.
    EOF
  }

  notification_channels = [
    "${google_monitoring_notification_channel.ghe-email.name}",
    "${google_monitoring_notification_channel.ghe-ops-slack.name}",
  ]
}

resource "google_monitoring_alert_policy" "ghe_deferred_mails" {
  display_name = "${var.prefix}GHE Deferred Mails"
  combiner     = "OR"
  enabled      = "${var.enabled}"

  conditions = {
    display_name = "${var.prefix}Mails Deferred"

    condition_threshold {
      filter          = "metric.type=\"custom.googleapis.com/github/filecount_files\" resource.type=\"gce_instance\" metadata.user_labels.\"env\"=\"${var.branch}\" metric.label.\"filecount\"=\"mail-deferred\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 10

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  documentation {
    content = <<EOF
Mails are deferred, Mailqueues are filling up.
    EOF
  }

  notification_channels = [
    "${google_monitoring_notification_channel.ghe-email.name}",
    "${google_monitoring_notification_channel.ghe-ops-slack.name}",
  ]
}

resource "google_monitoring_alert_policy" "ghe_elastic_index_status" {
  display_name = "${var.prefix}GHE Elasticsearch Index Status"
  combiner     = "OR"
  enabled      = "${var.enabled}"

  conditions = {
    display_name = "${var.prefix}Elasticsearch Indexes unhealthy"

    condition_threshold {
      filter          = "metric.type=\"custom.googleapis.com/github/ghe_es_index_status\" resource.type=\"gce_instance\" metadata.user_labels.\"env\"=\"${var.branch}\""
      duration        = "60s"
      comparison      = "COMPARISON_LT"
      threshold_value = 100

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  documentation {
    content = <<EOF
Elasticsearch Indexes of GHE unhealthy.
    EOF
  }

  notification_channels = [
    "${google_monitoring_notification_channel.ghe-email.name}",
    "${google_monitoring_notification_channel.ghe-ops-slack.name}",
  ]
}

resource "google_monitoring_alert_policy" "ghe_replication_status" {
  display_name = "${var.prefix}GHE Replication Status"
  combiner     = "OR"
  enabled      = "${var.enabled}"

  conditions = [{
    display_name = "${var.prefix}Repliaction Warning"

    condition_threshold {
      filter          = "metric.type=\"custom.googleapis.com/github/ghe_repl_status\" resource.type=\"gce_instance\" metadata.user_labels.\"env\"=\"${var.branch}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  },
    {
      display_name = "${var.prefix}Repliaction Error"

      condition_threshold {
        filter          = "metric.type=\"custom.googleapis.com/github/ghe_repl_status\" resource.type=\"gce_instance\" metadata.user_labels.\"env\"=\"${var.branch}\""
        duration        = "60s"
        comparison      = "COMPARISON_GT"
        threshold_value = 1

        aggregations {
          alignment_period   = "60s"
          per_series_aligner = "ALIGN_MEAN"
        }

        trigger {
          count = 1
        }
      }
    },
  ]

  documentation {
    content = <<EOF
GHE Replication Status is unhealthy.
    EOF
  }

  notification_channels = [
    "${google_monitoring_notification_channel.ghe-email.name}",
    "${google_monitoring_notification_channel.ghe-ops-slack.name}",
  ]
}
