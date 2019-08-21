resource "google_monitoring_notification_channel" "ghe-email" {
  display_name = "${var.prefix}GitHub Enterprise DL"
  type         = "email"

  labels = {
    email_address = "${var.support_email}"
  }
}

resource "google_monitoring_notification_channel" "ghe-ops-slack" {
  display_name = "${var.prefix}GHE Ops Slack Channel"
  type         = "slack"

  labels = {
    auth_token   = "${var.slack_hook}"
    channel_name = "${var.slack_channel}"
  }
}
