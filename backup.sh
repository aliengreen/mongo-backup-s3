
#! /bin/sh

set -eo pipefail

if [ "${S3_ACCESS_KEY_ID}" = "**None**" ]; then
  echo "You need to set the S3_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ "${S3_SECRET_ACCESS_KEY}" = "**None**" ]; then
  echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ "${S3_BUCKET}" = "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

# if [ "${MONGODB_DATABASE}" = "**None**" -a "${MONGODB_BACKUP_ALL}" != "true" ]; then
#   echo "You need to set the MONGODB_DATABASE environment variable."
#   exit 1
# fi

if [ "${MONGODB_HOST}" = "**None**" ]; then
  if [ -n "${MONGODB_PORT_27017_TCP_ADDR}" ]; then
    MONGODB_HOST=$MONGODB_PORT_27017_TCP_ADDR
    MONGODB_PORT=$MONGODB_PORT_27017_TCP_PORT
  else
    echo "You need to set the MONGODB_HOST environment variable."
    exit 1
  fi
fi

if [ "${MONGODB_USER}" != "**None**" ]; then
  echo "MONGODB_USER environment variable is not supported"
  exit 1
fi

if [ "${MONGODB_PASSWORD}" != "**None**" ]; then
  echo "MONGODB_PASSWORD environment variable is not supported"
  exit 1
fi

if [ "${S3_ENDPOINT}" == "**None**" ]; then
  AWS_ARGS=""
else
  AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
fi

# env vars needed for aws tools
export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$S3_REGION

export PGPASSWORD=$MONGODB_PASSWORD
MONGODB_HOST_OPTS="--host $MONGODB_HOST:$MONGODB_PORT"
# -U $MONGODB_USER $MONGODB_EXTRA_OPTS"

if [ -z ${S3_PREFIX+x} ]; then
  S3_PREFIX="/"
else
  S3_PREFIX="/${S3_PREFIX}/"
fi

if [ "${MONGODB_DATABASE}" == "**None**" ]; then
  SRC_FILE=dump.gz
  DEST_FILE=all_$(date +"%Y-%m-%dT%H:%M:%SZ").gz
  
  if [ "${S3_FILE_NAME}" != "**None**" ]; then
    DEST_FILE=${S3_FILE_NAME}.gz
  fi

  echo "Creating dump of all databases from ${MONGODB_HOST}..."
#   echo pg_dumpall -h $MONGODB_HOST -p $MONGODB_PORT -U $MONGODB_USER | gzip > $SRC_FILE
  mongodump $MONGODB_HOST_OPTS --gzip --archive > $SRC_FILE



  echo "Uploading dump to $S3_BUCKET"
  cat $SRC_FILE | aws $AWS_ARGS s3 cp - "s3://${S3_BUCKET}${S3_PREFIX}${DEST_FILE}" || exit 2

  echo "Mongo backup uploaded successfully"
  rm -rf $SRC_FILE
else
  OIFS="$IFS"
  IFS=','
  for DB in $MONGODB_DATABASE
  do
    IFS="$OIFS"

    SRC_FILE=dump.gz
    DEST_FILE=${DB}_$(date +"%Y-%m-%dT%H:%M:%SZ").gz

    if [ "${S3_FILE_NAME}" != "**None**" ]; then
      DEST_FILE=${S3_FILE_NAME}_${DB}.gz
    fi
    
    echo "Creating dump of ${DB} database from ${MONGODB_HOST}..."
    # echo  $MONGODB_HOST_OPTS $DB  gzip  $SRC_FILE
    mongodump $MONGODB_HOST_OPTS --db $DB --gzip --archive > $SRC_FILE
    

    echo "Uploading dump to $S3_BUCKET"
    cat $SRC_FILE | aws $AWS_ARGS s3 cp - "s3://${S3_BUCKET}${S3_PREFIX}${DEST_FILE}" || exit 2

    echo "Mongo backup uploaded successfully"
    rm -rf $SRC_FILE
  done
fi