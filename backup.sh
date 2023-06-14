#! /bin/sh

set -eu
set -o pipefail

source ./env.sh
for POSTGRES_DATABASE in $DATABASES; do
echo "Creating backup of $POSTGRES_DATABASE database..."
pg_dump --format=custom \
        -h $POSTGRES_HOST \
        -p $POSTGRES_PORT \
        -U $POSTGRES_USER \
        -d $POSTGRES_DATABASE \
        $PGDUMP_EXTRA_OPTS \
        > db.dump

timestamp=$(date +"%Y-%m-%dT%H:%M:%S")
s3_uri_base="s3://${S3_BUCKET}/${POSTGRES_DATABASE}/${POSTGRES_DATABASE}_${timestamp}.dump"

if [ -n "$PASSPHRASE_FILE" ]; then
  export PASSPHRASE=$(cat ${PASSPHRASE_FILE})
  echo "Encrypting backup..."
  gpg --symmetric --batch --passphrase "$PASSPHRASE" db.dump
  if [ $? -eq 0 ]; then
    rm db.dump
    local_file="db.dump.gpg"
    s3_uri="${s3_uri_base}.gpg"
  else
    >&2 curl -X POST -F "body=Error encrypting dump of ${POSTGRES_DATABASE}" -F 'title=Postgresql Backup Error' ${NOTIFICATIONS_SERVER_URL}
  fi
else
  local_file="db.dump"
  s3_uri="$s3_uri_base"
fi

echo "Uploading backup to $S3_BUCKET..."
aws $aws_args s3 cp "$local_file" "$s3_uri"
if [ $? -eq 0 ]; then
  rm "$local_file"
else
  >&2 curl -X POST -F "body=Error uploading dump of ${POSTGRES_DATABASE} to s3" -F 'title=Postgresql Backup Error' ${NOTIFICATIONS_SERVER_URL}
fi
done

echo "Backup complete."

if [ -n "$BACKUP_KEEP_DAYS" ]; then
  sec=$((86400*BACKUP_KEEP_DAYS))
  date_from_remove=$(date -d "@$(($(date +%s) - sec))" +%Y-%m-%d)
  backups_query="Contents[?LastModified<='${date_from_remove} 00:00:00'].{Key: Key}"

  echo "Removing old backups from $S3_BUCKET..."
  aws $aws_args s3api list-objects \
    --bucket "${S3_BUCKET}" \
    --query "${backups_query}" \
    --output text \
    | xargs -n1 -t -I 'KEY' aws $aws_args s3 rm s3://"${S3_BUCKET}"/'KEY'
  if [ $? -eq 0 ]; then
    echo "Removal complete."
  else
    >&2 curl -X POST -F "body=Error cleaning up old backups" -F 'title=Postgresql Backup Error' ${NOTIFICATIONS_SERVER_URL}
  fi
fi

curl ${WEBHOOK}