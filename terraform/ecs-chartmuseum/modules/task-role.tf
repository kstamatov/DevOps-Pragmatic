resource aws_iam_role exec_role {
  name_prefix = "exec-role"
  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow"
        Action: "sts:AssumeRole",
        Principal: {
          AWS: "*"
        }
      }
    ]
  })
}

resource aws_iam_role_policy exec_policy {
  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow"
        Action: [
          "ecs:*",
          "ecr:*",
          "logs:*"
        ]
        Resource: "*"
      }
    ]
  })
  role = aws_iam_role.exec_role.id
}

resource aws_iam_role s3_role {
  name_prefix = "exec-role"
  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow"
        Action: "sts:AssumeRole",
        Principal: {
          AWS: "*"
        }
      }
    ]
  })
}

resource aws_iam_role_policy s3_policy {
  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow"
        Action: [
          "s3:*"
        ]
        Resource: "*"
      }
    ]
  })
  role = aws_iam_role.s3_role.id
}