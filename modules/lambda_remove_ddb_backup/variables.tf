variable "ddb_backup_retention_in_years" {
  default = 2
}
variable "lambda_log_retention_in_days" {
  default = 90
}
variable "lambda_role" {}
variable "name" {
  default = "remove_ddb_backup"
}
variable "schedule_exp" {
  default = "cron(0 0 2 * ? *)"
}
