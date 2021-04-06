#!/bin/sh

CONFIGFILE=/config/.dropbox_uploader
if [ ! -f "$CONFIGFILE" ]; then
    echo "Configfile not found! First run setup.sh" >> /logs/bitwarden_backup.log
    exit 0
fi

# create backup filename
BACKUP_FILE="${BACKUP_PREFIX}_$(date "+%F-%H%M%S")"

# use sqlite3 to create backup (avoids corruption if db write in progress)
sqlite3 /data/db.sqlite3 ".backup '/tmp/db.sqlite3'"

# tar up backup and encrypt with openssl and encryption key
tar -czf - /tmp/db.sqlite3 /data/attachments | openssl enc -e -aes256 -salt -pbkdf2 -pass pass:${BACKUP_ENCRYPTION_KEY} -out /tmp/${BACKUP_FILE}.tar.gz

echo "Creating backup: ${BACKUP_FILE}.tar.gz" >> /logs/bitwarden_backup.log

# upload encrypted tar to dropbox
/dropbox_uploader.sh -f /config/.dropbox_uploader upload /tmp/${BACKUP_FILE}.tar.gz /${BACKUP_FILE}.tar.gz

echo "Uploaded backup: ${BACKUP_FILE}.tar.gz" >> /logs/bitwarden_backup.log

# copy to backups folder if env is given
if [ ! -z "$KEEP_LOCAL_BACKUPS" ] && [ $KEEP_LOCAL_BACKUPS -eq 1 ]
then
  echo "Saved backup locally" >> /logs/bitwarden_backup.log
  cp /tmp/${BACKUP_FILE}.tar.gz /backups/${BACKUP_FILE}.tar.gz
fi

# cleanup tmp folder
rm -rf /tmp/*

# delete older backups if variable is set & greater than 0
if [ ! -z $DELETE_AFTER ] && [ $DELETE_AFTER -gt 0 ]
then
  /backup-delete.sh
fi
