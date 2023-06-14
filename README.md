# Introduction  
Backup selected Postgresql databases to S3 compatible backend 


## Environment variables

- `DATABASES` list of databases you want to backup
- `POSTGRES_HOST` the postgresql host *required*
- `POSTGRES_PORT` the postgresql port (default: 5432)
- `POSTGRES_USER_FILE` the postgresql user if you use a docker swarm secret *required*
- `POSTGRES_PASSWORD_FILE` the postgresql password if you use a docker swarm secret *required*
- `PASSPHRASE_FILE` the file containing password used to encrypt dumps *required*
- `S3_ACCESS_KEY_ID_FILE` your AWS access key if you use a docker swarm secret *required*
- `S3_SECRET_ACCESS_KEY_FILE` your AWS secret key if you use a docker swarm secret*required*
- `S3_BUCKET` your AWS S3 bucket path *required*
- `NOTIFICATIONS_SERVER_URL` your apprise-api server URL*required*
- `S3_FILENAME` a consistent filename to overwrite with your backup.  If not set will use a timestamp.
- `S3_REGION` the AWS S3 bucket region (default: us-west-1)
- `S3_ENDPOINT` the AWS Endpoint URL, for S3 Compliant APIs such as [minio](https://minio.io) (default: none)
- `SCHEDULE` variable determines backup frequency. See go-cron schedules documentation [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules). Omit to run the backup immediately and then exit.
- `BACKUP_KEEP_DAYS` if set, backups older than this many days will be deleted from S3
- `WEBHOOK` these will be passed to curl and executed at the end of backup script
