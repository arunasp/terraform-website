# S3 Bucket Policy

data "aws_caller_identity" "current" {}

data "template_file" "this_users_arn" {
  count = var.create && length(var.users) > 0 ? length(var.users) : 0

  template = "\"$${arn}\""

  vars = {
    arn = var.users[count.index]
  }
}

data "template_file" "this_bucket_policy" {
  count = var.create && length(var.users) > 0 ? length(var.users) : 0

  template = file("${path.module}/bucket-policy/policy.json.tpl")

  vars = {
    bucket      = aws_s3_bucket.this[count.index].arn
    key         = var.kms_key_arn
    users       = join(",", data.template_file.this_users_arn.*.rendered)
    deploy_user = "\"${data.aws_caller_identity.current.arn}\""
  }
}
