#!/bin/sh

CONFIGFILE=/config/.dropbox_uploader
if [ ! -f "$CONFIGFILE" ]; then
    echo "Configfile not found! First run setup.sh" >> /logs/bitwarden_backup.log
    exit 0
fi

# create backup filename
BACKUP_FILE="${BACKUP_PREFIX}_$(date "+%F-%H%M%S")"

echo " " >> /logs/bitwarden_backup.log
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> /logs/bitwarden_backup.log
echo "Starting backup process..." >> /logs/bitwarden_backup.log

# use sqlite3 to create backup (avoids corruption if db write in progress)
sqlite3 /data/db.sqlite3 ".backup '/tmp/db.sqlite3'"

# tar up backup and encrypt with openssl and encryption key
echo "Creating backup: ${BACKUP_FILE}.tar.gz" >> /logs/bitwarden_backup.log
tar -czf - /tmp/db.sqlite3 /data/attachments | openssl enc -e -aes256 -salt -pbkdf2 -pass pass:${BACKUP_ENCRYPTION_KEY} -out /tmp/${BACKUP_FILE}.tar.gz
echo "Created backup." >> /logs/bitwarden_backup.log


# upload encrypted tar to dropbox
echo "Uploading backup to Dropbox." >> /logs/bitwarden_backup.log
/dropbox_uploader.sh -f /config/.dropbox_uploader upload /tmp/${BACKUP_FILE}.tar.gz /${BACKUP_FILE}.tar.gz
echo "Uploaded backup to Dropbox." >> /logs/bitwarden_backup.log

# copy to backups folder if env is given
if [ ! -z "$KEEP_LOCAL_BACKUPS" ] && [ $KEEP_LOCAL_BACKUPS -eq 1 ]
then
  echo "Saving backup locally." >> /logs/bitwarden_backup.log
  cp /tmp/${BACKUP_FILE}.tar.gz /backups/${BACKUP_FILE}.tar.gz
else
  echo "Saving backup locally >> disabled <<" >> /logs/bitwarden_backup.log
fi

# cleanup tmp folder
rm -rf /tmp/*

echo " " >> /logs/bitwarden_backup.log
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> /logs/bitwarden_backup.log
echo " " >> /logs/bitwarden_backup.log

# delete older backups if variable is set & greater than 0
if [ ! -z $DELETE_AFTER ] && [ $DELETE_AFTER -gt 0 ]
then
  /backup-delete.sh
fi
