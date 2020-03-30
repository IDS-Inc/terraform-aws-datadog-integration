data "aws_iam_policy_document" "core" {
  statement {
    sid    = "DatadogCore"
    effect = "Allow"

    actions = [
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "ec2:Describe*",
      "support:*",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",
    ]

    resources = ["*"]
  }
}

locals {
  core_count = contains(split(",", lower(join(",", var.integrations))), "core") ? 1 : 0
}

resource "aws_iam_policy" "core" {
  count  = local.core_count
  name   = "${local.name}-core"
  policy = data.aws_iam_policy_document.core.json
}

resource "aws_iam_role_policy_attachment" "core" {
  count      = local.core_count
  role       = aws_iam_role.default.name
  policy_arn = join("", aws_iam_policy.core.*.arn)
}

