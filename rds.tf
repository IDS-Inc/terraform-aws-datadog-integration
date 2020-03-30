data "aws_iam_policy_document" "rds" {
  statement {
    sid    = "DatadogRDS"
    effect = "Allow"

    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "ec2:Describe*",
      "ec2:Get*",
      "logs:Get*",
      "logs:Describe*",
      "logs:FilterLogEvents",
      "logs:TestMetricFilter",
      "rds:Describe*",
      "rds:List*",
      "tag:getResources",
      "tag:getTagKeys",
      "tag:getTagValues",
    ]

    resources = ["*"]
  }
}

locals {
  rds_count = contains(split(",", lower(join(",", var.integrations))), "rds") ? 1 : 0
}

resource "aws_iam_policy" "rds" {
  count  = local.rds_count
  name   = "${local.name}-rds"
  policy = data.aws_iam_policy_document.rds.json
}

resource "aws_iam_role_policy_attachment" "rds" {
  count      = local.rds_count
  role       = aws_iam_role.default.name
  policy_arn = join("", aws_iam_policy.rds.*.arn)
}

