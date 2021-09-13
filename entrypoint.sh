#!/bin/sh

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> /logs/bitwarden_backup.log
echo "(Re)started the Bitwarden_rs Dropbox backup container" >> /logs/bitwarden_backup.log
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> /logs/bitwarden_backup.log
echo " " >> /logs/bitwarden_backup.log
echo "$CRON_EXPRESSION /backup-bitwarden.sh" > /etc/crontabs/root

#make config and backup directories
mkdir /config
mkdir /backups

if [ ! -d "/data/attachments" ]
then
    mkdir /data/attachments
fi

mkdir /logs
touch /logs/bitwarden_backup.log
chmod 770 /logs/bitwarden_backup.log

# setup dropbox uploader config file
# /dropbox_uploader.sh -f /config/.dropbox_uploader info

CONFIGFILE=/config/.dropbox_uploader
if [ -f "$CONFIGFILE" ]; then 
    /dropbox_uploader.sh -f /config/.dropbox_uploader info >> /logs/bitwarden_backup.log
fi

# run backup once on container start to ensure it works
/backup-bitwarden.sh

# start crond in foreground
exec crond -f

