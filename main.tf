data "aws_iam_policy_document" "trust_relationship" {
  statement {
    sid     = "DatadogAWSTrustRelationship"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${var.datadog_aws_account_id}:root",
      ]
    }
  }
}

resource "aws_iam_role" "default" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.trust_relationship.json

  lifecycle {
    ignore_changes = [assume_role_policy]
  }
}

resource "datadog_integration_aws" "default" {
  account_id  = data.aws_caller_identity.current.account_id
  role_name   = aws_iam_role.default.name
  filter_tags = var.filter_tags
  host_tags = [
    "datadog:monitored",
    "env:${var.environment_name}",
  ]
  account_specific_namespace_rules = {
    auto_scaling = false
    opsworks     = false
  }
}

resource "null_resource" "role_policy" {
  provisioner "local-exec" {
    command = "python3 ${path.module}/scripts/update_assume_role.py --account_id ${data.aws_caller_identity.current.account_id} --role_name=${aws_iam_role.default.name} --datadog_external_id=${datadog_integration_aws.default.external_id}"
  }
}