{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowDecryptWithKMSKey",
            "Effect": "Allow",
            "Action": [
                "kms:ListKeys",
                "kms:ListAliases",
                "kms:DescribeKey",
                "kms:ListKeyPolicies",
                "kms:GetKeyPolicy",
                "kms:GetKeyRotationStatus",
                "kms:Decrypt"
            ],
            "Resource": "arn:aws:ssm:${aws_region}:${aws_account_id}:key/${kms_key_id}"
        },
        {
            "Action": [
            "ec2:DescribeInstances"
            ],
                "Effect": "Allow",
            "Resource": [
                "*"
            ]
        },
        {
            "Action": [
            "iam:ListInstanceProfiles",
            "sts:AssumeRole",
            "sts:PassRole"
            ],
                "Effect": "Allow",
            "Resource": [
                "arn:aws:iam::${aws_account_id}:instance-profile/${instance_profile}"
            ]
        }
    ]
}
