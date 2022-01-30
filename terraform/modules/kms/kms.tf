resource "aws_kms_key" "this" {
  count       = var.create && var.create_default_resources ? 1 : 0
  description = "${var.stack}-${var.stage} ${var.name} key in ${var.region}"
  policy      = data.aws_iam_policy_document.this_kms_policy.json
}

resource "aws_kms_alias" "this" {
  count         = var.create && var.create_default_resources ? 1 : 0
  name          = "alias/${var.stack}-${var.stage}-${var.name}"
  target_key_id = aws_kms_key.this[count.index].key_id
}
