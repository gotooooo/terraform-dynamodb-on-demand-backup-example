data "archive_file" "create_ddb_backup" {
  output_path = "${path.module}/${var.name}.zip"
  source_dir  = "${path.module}/${var.name}"
  type        = "zip"
}

resource "aws_lambda_function" "create_ddb_backup" {
  function_name = var.name
  role          = var.lambda_role.arn
  handler       = "index.handler"

  filename         = data.archive_file.create_ddb_backup.output_path
  source_code_hash = data.archive_file.create_ddb_backup.output_base64sha256

  runtime = "nodejs14.x"
  timeout = 30

  environment {
    variables = {
      tables = jsonencode(var.tables)
    }
  }

  depends_on = [aws_cloudwatch_log_group.create_ddb_backup]
}

resource "aws_cloudwatch_event_rule" "create_ddb_backup" {
  name                = var.name
  description         = "backup ddb"
  schedule_expression = var.schedule_exp
}

resource "aws_cloudwatch_event_target" "create_ddb_backup" {
  rule      = aws_cloudwatch_event_rule.create_ddb_backup.name
  target_id = var.name
  arn       = aws_lambda_function.create_ddb_backup.arn
}

resource "aws_lambda_permission" "create_ddb_backup" {
  statement_id  = "AllowExecutionFromCloudWatchEventCreateDdbBackup"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_ddb_backup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.create_ddb_backup.arn
}

resource "aws_cloudwatch_log_group" "create_ddb_backup" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.lambda_log_retention_in_days
}
