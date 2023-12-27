# mongo-backup-s3

[![Docker Hub Link][docker-img]][docker-url]

Backup MongoDB to S3 (supports periodic backups) it based on https://github.com/schickling/dockerfiles/tree/master/postgres-backup-s3



## Usage

Run using `docker run`  command, which is an alternative to using Docker Compose to run a Docker container. This command is designed to run the `aliengreenllc/mongo-backup-s3` container with environment variables set for configuration. 

```shell
docker run \
  -e S3_ENDPOINT=https://ams3.digitaloceanspaces.com \
  -e S3_ACCESS_KEY_ID=key \
  -e S3_SECRET_ACCESS_KEY=secret \
  -e S3_BUCKET=buketname \
  -e S3_PREFIX=backup \
  -e MONGODB_HOST=mdb-host \
  -e MONGODB_DATABASE=dbname \
  aliengreenllc/mongo-backup-s3
```

> NOTE: you can specify network with parameter `--network=name`

- `S3_ENDPOINT`: The URL of the S3 endpoint, in this case, [https://ams3.digitaloceanspaces.com](https://ams3.digitaloceanspaces.com/).
- `S3_ACCESS_KEY_ID`: The access key ID for connecting to the specified S3 bucket.
- `S3_SECRET_ACCESS_KEY`: The secret access key associated with the access key ID.
- `S3_BUCKET`: The name of the S3 bucket where the backups will be stored.
- `S3_PREFIX`: The prefix or folder name within the S3 bucket where the backups will be stored.
- `MONGODB_HOST`: The host address of the MongoDB instance, in this case, `mdb-host`.
- `MONGODB_DATABASE`:  Specifies the name of the MongoDB database to be backed up. If this parameter is omitted, all databases are backed up. You can also specify multiple database names by separating them with commas. For example: `db_name1,db_name2`.
- `aliengreenllc/mongo-backup-s3`: The Docker image to be run.

### Automatic Periodic Backups

You can also set the `SCHEDULE` environment variable, for example, `-e SCHEDULE="@daily"`, to run the backup automatically at specified intervals.

More information about the intervals can be found [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

A useful interval format is `@every <duration>`, where `<duration>` is a string accepted by `time.ParseDuration` (http://golang.org/pkg/time/#ParseDuration). For example, if you need to quickly test if scheduling is set up correctly, you can specify `@every 2m`, indicating that the schedule runs every 2 minutes.

> NOTE:  The interval does not take the job runtime into account. For instance, if a job takes 3 minutes to run and is scheduled to run every 2 minutes, it will not have idle time between each run, and the next job will start immediately after the previous one ends.

### Backup File Name / Path

By default, if `MONGODB_DATABASE` is not specified, the dump file will be put at `<S3_PREFIX=''>/all_<timestamp>.gz`. When using `MONGODB_DATABASE`, each database listed will be backed up to the object path `<S3_PREFIX=''>/<database>_<timestamp>.gz`.

If you wish to make these filenames static, you can use the `S3_FILE_NAME` variable, which will change these formats to `<S3_PREFIX=''>/<S3_FILE_NAME>.gz` or `<S3_PREFIX=''>/<S3_FILE_NAME>_<database>.gz` accordingly.

### Backup All Databases

You can backup all available databases by ommiting `MONGODB_DATABASE`.

Single archive with the name `all_<timestamp>.gz` will be uploaded to S3

### Endpoints for S3

An Endpoint is the URL of the entry point for an AWS web service or S3 Compitable Storage Provider.

You can specify an alternate endpoint by setting `S3_ENDPOINT` environment variable like `protocol://endpoint` e.g. [https://ams3.digitaloceanspaces.com](https://ams3.digitaloceanspaces.com/) for DigitalOcean Space.

>  NOTE: S3 Compitable Storage Provider requires `S3_ENDPOINT` environment variable



Docker composer:

```yaml
backdb-backup:
    container_name: backdb-backup
    image: aliengreenllc/mongo-backup-s3
    environment:
      S3_ENDPOINT: "https://ams3.digitaloceanspaces.com"
      S3_ACCESS_KEY_ID: "key"
      S3_SECRET_ACCESS_KEY: "secret"
      S3_BUCKET: "buketname"
      S3_PREFIX: "backup"
      MONGODB_HOST: "mdb-host"
      MONGODB_DATABASE: "dbname"
    networks:
      - db_network
```

This snipet defines a service named `backdb-backup` for backing up a MongoDB database using the `aliengreenllc/mongo-backup-s3`  image. The backup service is configured to store backups in an S3 bucket hosted on AWS or DigitalOcean Spaces. The minimal configuration includes specifying the S3 endpoint, access key ID, secret access key, S3 bucket name, S3 prefix (which serves as the folder name in the bucket), MongoDB host, and the name of the MongoDB database to be backed up. Additionally, the service is connected to a network named `db_network`, which should be the same network where the MongoDB database container is running. The `S3_PREFIX` parameter effectively corresponds to the folder within the specified `S3_BUCKET`.

To see all available versions: <https://hub.docker.com/r/aliengreenllc/mongo-backup-s3/tags/>



## Limitations

- There is no support for database usernames and passwords, but it can be easily added. Unfortunately, I don't have the time to test and implement this functionality at the moment.




## License

[MIT](LICENSE)

[docker-img]: https://img.shields.io/badge/docker-ready-blue.svg
[docker-url]: https://hub.docker.com/r/aliengreenllc/mongo-backup-s3