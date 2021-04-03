#!/bin/sh

echo "$CRON_EXPRESSION /backup-bitwarden.sh" > /etc/crontabs/root

#make config and backup directories
mkdir /config
mkdir /backups

# setup dropbox uploader config file
/dropbox_uploader.sh -f /config/.dropbox_uploader info

# run backup once on container start to ensure it works
/backup-bitwarden.sh

# start crond in foreground
exec crond -f