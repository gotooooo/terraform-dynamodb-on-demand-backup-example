data "archive_file" "remove_ddb_backup" {
  output_path = "${path.module}/${var.name}.zip"
  source_dir  = "${path.module}/${var.name}"
  type        = "zip"
}

resource "aws_lambda_function" "remove_ddb_backup" {
  function_name = var.name
  role          = var.lambda_role.arn
  handler       = "index.handler"

  filename         = data.archive_file.remove_ddb_backup.output_path
  source_code_hash = data.archive_file.remove_ddb_backup.output_base64sha256

  runtime = "nodejs14.x"
  timeout = 30

  environment {
    variables = {
      ddb_backup_retention_in_years = var.ddb_backup_retention_in_years
    }
  }

  depends_on = [aws_cloudwatch_log_group.remove_ddb_backup]
}

resource "aws_cloudwatch_event_rule" "remove_ddb_backup" {
  name                = var.name
  description         = "remove old ddb backups"
  schedule_expression = var.schedule_exp
}

resource "aws_cloudwatch_event_target" "remove_ddb_backup" {
  rule      = aws_cloudwatch_event_rule.remove_ddb_backup.name
  target_id = var.name
  arn       = aws_lambda_function.remove_ddb_backup.arn
}

resource "aws_lambda_permission" "remove_ddb_backup" {
  statement_id  = "AllowExecutionFromCloudWatchEventRemoveDdbBackup"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.remove_ddb_backup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.remove_ddb_backup.arn
}

resource "aws_cloudwatch_log_group" "remove_ddb_backup" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.lambda_log_retention_in_days
}
