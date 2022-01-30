{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket*",
        "s3:GetBucket*",
        "s3:DeleteBucket*"
      ],
      "Resource": ["${bucket}"],
      "Principal": {
        "AWS": [${users}, ${deploy_user}]
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject*",
        "s3:DeleteObject*",
        "s3:PutObject*",
        "s3:ReplicateObject",
        "s3:RestoreObject"
      ],
      "Resource": [
        "${bucket}/*"
      ],
      "Principal": {
        "AWS": [${users}, ${deploy_user}]
      }
    }
  ]
}
