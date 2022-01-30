resource "aws_iam_role" "this" {
  count              = var.create ? 1 : 0
  name               = var.name
  assume_role_policy = var.trust_policy
  path               = var.path
}

resource "aws_iam_policy" "this" {
  count       = var.create && length(var.role_policies) > 0 ? length(var.role_policies) : 0
  name        = length(var.role_policies) > 1 ? "${var.name}-${count.index}" : var.name
  description = "Custom IAM policy for managing the permissions of role: [${var.name}]"
  path        = var.path
  policy      = var.role_policies[count.index]
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.create && length(var.role_policies) > 0 ? length(var.role_policies) : 0
  role       = aws_iam_role.this.0.name
  policy_arn = element(aws_iam_policy.this.*.arn, count.index)
}

resource "aws_iam_instance_profile" "this" {
  count = var.create && var.is_instance_profile ? 1 : 0
  name  = var.name
  role  = aws_iam_role.this.0.name
}
