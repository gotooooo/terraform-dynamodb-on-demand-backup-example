output "create_ddb_backup_role" {
  value = aws_iam_role.create_ddb_backup_role
}

output "remove_ddb_backup_role" {
  value = aws_iam_role.remove_ddb_backup_role
}
