if [ -z "$S3_BUCKET" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ -z "$DATABASES" ]; then
  echo "You need to set the DATABASES environment variable."
  exit 1
fi

if [ -z "$NOTIFICATIONS_SERVER_URL" ]; then
  echo "You need to set the NOTIFICATIONS_SERVER_URL"
  exit 1
fi

if [ -z "$POSTGRES_HOST" ]; then
  # https://docs.docker.com/network/links/#environment-variables
  if [ -n "$POSTGRES_PORT_5432_TCP_ADDR" ]; then
    POSTGRES_HOST=$POSTGRES_PORT_5432_TCP_ADDR
    POSTGRES_PORT=$POSTGRES_PORT_5432_TCP_PORT
  else
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
  fi
fi

if [ -z "$POSTGRES_USER_FILE" ]; then
  echo "You need to set the POSTGRES_USER_FILE environment variable."
  exit 1
fi

if [ -z "$POSTGRES_PASSWORD_FILE" ]; then
  echo "You need to set the POSTGRES_PASSWORD_FILE environment variable."
  exit 1
fi

if [ -z "$S3_ENDPOINT" ]; then
  aws_args=""
else
  aws_args="--endpoint-url $S3_ENDPOINT"
fi


if [ -n "$S3_ACCESS_KEY_ID_FILE" ]; then
  export AWS_ACCESS_KEY_ID=$(cat ${S3_ACCESS_KEY_ID})
fi
if [ -n "$S3_SECRET_ACCESS_KEY_FILE" ]; then
  export AWS_SECRET_ACCESS_KEY=$(cat ${S3_SECRET_ACCESS_KEY})
fi
export AWS_DEFAULT_REGION=$S3_REGION
export PGPASSWORD=$(cat ${POSTGRES_PASSWORD_FILE})
export POSTGRES_USER=$(cat ${POSTGRES_USER_FILE})
