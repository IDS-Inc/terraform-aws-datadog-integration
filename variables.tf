data "aws_caller_identity" "current" {}
variable "account_name" {
  description = "Name of the AWS Account"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "datadog_aws_account_id" {
  description = "The AWS account ID Datadog's integration servers use for all integrations"
  default     = "464622532012"
}

variable "integrations" {
  type        = list(string)
  description = "List of AWS permission names to apply for different integrations (`all`, `core`, `rds`)"
}

variable "filter_tags" {
  type        = list(string)
  description = "Array of EC2 tags (in the form key:value) defines a filter that Datadog use when collecting metrics from EC2. Wildcards, such as ? (for single characters) and * (for multiple characters) can also be used."
  default     = []
}

variable "environment_name" {
  description = "Name of the environment (<team><environment>)"
}

locals {
  name = "${var.account_name}-datadogintegration"
}
