data "aws_iam_policy_document" "lambda" {
  statement {
    sid    = "DatadogLambd"
    effect = "Allow"

    actions = [
      "lambda:List*",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:FilterLogEvents",
      "tag:GetResources",
    ]

    resources = ["*"]
  }
}

locals {
  lambda_count = contains(split(",", lower(join(",", var.integrations))), "lambda") ? 1 : 0
}

resource "aws_iam_policy" "lambda" {
  count  = local.lambda_count
  name   = "${local.name}-lambda"
  policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  count      = local.lambda_count
  role       = aws_iam_role.default.name
  policy_arn = join("", aws_iam_policy.lambda.*.arn)
}

