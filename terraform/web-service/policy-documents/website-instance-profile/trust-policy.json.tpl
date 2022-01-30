{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowEC2AssumeRole",
            "Effect": "Allow",
            "Principal": {
                "Service": ["ec2.amazonaws.com", "sts.amazonaws.com"]
            },
            "Action": [
                "sts:AssumeRole"
            ]
        }
    ]
}
