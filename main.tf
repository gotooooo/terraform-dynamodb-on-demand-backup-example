terraform {
  required_version = ">= 1.0.7"
  backend "s3" {
    bucket         = "mybucket"
    key            = "path/to/my/key.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

module "iam" {
  source = "./modules/iam"
}

module "lambda_create_ddb_backup" {
  source = "./modules/lambda_create_ddb_backup"

  lambda_role = module.iam.create_ddb_backup_role
  tables = [
    "hoge-table",
    "fuga-table",
    "piyo-table"
  ]
}

module "lambda_remove_ddb_backup" {
  source = "./modules/lambda_remove_ddb_backup"

  lambda_role = module.iam.remove_ddb_backup_role
}
