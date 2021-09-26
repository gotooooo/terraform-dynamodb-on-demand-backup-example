variable "lambda_log_retention_in_days" {
  default = 90
}
variable "lambda_role" {}
variable "name" {
  default = "create_ddb_backup"
}
variable "schedule_exp" {
  default = "cron(0 0 1 * ? *)"
}
variable "tables" {}
