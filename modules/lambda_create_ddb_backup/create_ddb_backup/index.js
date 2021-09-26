'use strict'

const AWS = require('aws-sdk')
AWS.config.update({ region: 'ap-northeast-1' })
const ddb = new AWS.DynamoDB({ apiVersion: '2012-08-10' })

const getTimestamp = () => {
  return (new Date)
    .toLocaleString("sv", { timeZone: "UTC" })
    .replace(/\D/g, "")
}

exports.handler = async () => {
  const tables = JSON.parse(process.env.tables)

  await Promise.all(tables.map(async (table) => {
    const params = {
      BackupName: `${table}_${getTimestamp()}`,
      TableName: table,
    }
    await ddb.createBackup(params).promise()
  }))
}
