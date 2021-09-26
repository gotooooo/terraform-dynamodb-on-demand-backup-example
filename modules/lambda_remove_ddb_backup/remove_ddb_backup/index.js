'use strict'

const AWS = require('aws-sdk')
AWS.config.update({ region: 'ap-northeast-1' })
const ddb = new AWS.DynamoDB({ apiVersion: '2012-08-10' })

const sleep = (msec) => new Promise(resolve => setTimeout(resolve, msec))

exports.handler = async () => {
  const now = new Date
  const timeRangeUpperBound = new Date(now.setFullYear(now.getFullYear() - process.env.ddb_backup_retention_in_years))

  const listBackups = async (lastEvaluatedBackupArn = undefined, backupArns = []) => {
    const params = {
      BackupType: 'USER',
      Limit: 100,
      TimeRangeUpperBound: timeRangeUpperBound,
      ExclusiveStartBackupArn: lastEvaluatedBackupArn
    }
    const result = await ddb.listBackups(params).promise()
    result.BackupSummaries.forEach((summary) => {
      backupArns.push(summary.BackupArn)
    })
    if (result.LastEvaluatedBackupArn !== undefined) {
      await sleep(200)
      return await listBackups(result.LastEvaluatedBackupArn, backupArns)
    } else {
      return backupArns
    }
  }

  const backupArns = await listBackups()
  await Promise.all(backupArns.map(async (backupArn) => {
    const params = {
      BackupArn: backupArn
    }
    await ddb.deleteBackup(params).promise()
  }))
}
