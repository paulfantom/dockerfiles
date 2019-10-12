# restic-mysql

## Description

Allow easy way to backup files or mysql databases using restic software while exporting data to prometheus monitoring system.

Monitoring works only when there is node_exporter with textfile collector enabled.

## Usage

Script is running once a day at hour defined in `WHEN` environment variable. If neccessary, backup can be enforced
during startup by specifying `--now` cli flag. After performing initial backup, script will next perform backups at hour
specified in `WHEN` variable.

Restic configuration is done by using environment variables. More about this can be found in restic documentation.

Script has an option to prune/forget repository data. This is internally done by executing
`restic forget --prune $RESTIC_FORGET`, where `RESTIC_FORGET` is an environment variable which can be specified during
container startup.

Script can perform backup in two modes. In first mode it will backup files from directory specified in `DATA_DIRECTORY`.
Second mode is used to backup mysql database and to enable this mode of operation, following variables need to be specified:
```
MYSQL_HOST
MYSQL_USER
$MYSQL_PASSWORD
MYSQL_DATABASE
```

Container can be started using following example:

```yaml
---
version: '3'

services:
  web-restic:
    image: quay.io/paulfantom/restic-mysql:latest
    restart: always
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /srv/web:/data:ro
      - /var/lib/node_exporter:/metrics
    environment:
      WHEN: "01:22"
      RESTIC_REPOSITORY: "restic_repo"
      DATA_DIRECTORY: "/data"
      RESTIC_ARGS: "-v"
      RESTIC_FORGET: "--keep-daily 7 --keep-weekly 8 --keep-monthly 24"
```


