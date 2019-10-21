variable "notification_topic_name" {
  default = "s3_event_notification"
  type = string
}

variable "bucket_name" {
  default = "event-test-pawel-d"
  type = string
}

variable "lambda_name" {
  default = "bucket-notification"
  type = string
}

variable "sender_email" {
  default = "pawel_dziadek@epam.com"
  type = string
}

variable "sender" {
  default = "Paweł Dziadek <pawel_dziadek@epam.com>"
  type = string
}

variable "recipient" {
  default = "pawel_dziadek@epam.com"
  type = string
}