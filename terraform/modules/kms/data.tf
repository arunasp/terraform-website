data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

# https://docs.aws.amazon.com/kms/latest/developerguide/services-s3.html#s3-customer-cmk-policy

data "aws_iam_policy_document" "this_kms_policy" {
  policy_id = "${var.stack}-${var.stage}-${var.region}-key-policy-s3"
  statement {
    sid = "Enable IAM User Permissions"
    actions = [
      "kms:*",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        format(
          "arn:%s:iam::%s:root",
          data.aws_partition.current.partition,
          data.aws_caller_identity.current.account_id
        ),
        "arn:aws:iam::${var.account_id}:root"
      ]
    }
    resources = ["*"]
  }
  statement {
    sid = "AllowFull"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["s3.*.amazonaws.com"]
    }
  }
}
