# common data sources and resources
data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name   = "lambda_logging"
  policy = data.aws_iam_policy_document.lambda_logging.json
}

# create ddb backup role
resource "aws_iam_role" "create_ddb_backup_role" {
  name               = "create_ddb_backup_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

resource "aws_iam_policy" "create_ddb_backup_policy" {
  name        = "create_ddb_backup_policy"
  path        = "/"
  description = "IAM policy for creating ddb backups from a lambda"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "dynamodb:CreateBackup",
        ],
        Resource : "arn:aws:dynamodb:*:*:*",
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "create_ddb_backup_role_lambda_logging_attachment" {
  role       = aws_iam_role.create_ddb_backup_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "create_ddb_backup_role_create_ddb_backup_policy_attachment" {
  role       = aws_iam_role.create_ddb_backup_role.name
  policy_arn = aws_iam_policy.create_ddb_backup_policy.arn
}

# remove ddb backup role
resource "aws_iam_role" "remove_ddb_backup_role" {
  name               = "remove_ddb_backup_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

resource "aws_iam_policy" "remove_ddb_backup" {
  name        = "remove_ddb_backup_policy"
  path        = "/"
  description = "IAM policy for removing ddb backups from a lambda"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "dynamodb:ListBackups",
          "dynamodb:DeleteBackup",
        ],
        Resource : "arn:aws:dynamodb:*:*:*",
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "remove_ddb_backup_role_lambda_logging_attachment" {
  role       = aws_iam_role.remove_ddb_backup_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "remove_ddb_backup_role_remove_ddb_backup_attachment" {
  role       = aws_iam_role.remove_ddb_backup_role.name
  policy_arn = aws_iam_policy.remove_ddb_backup.arn
}
