#!/bin/bash

# Seconds since epoch for current time
DATE_NOW=$(date +%s)

TOTALBACKUPS=$(/dropbox_uploader.sh -f /config/.dropbox_uploader list | grep "${BACKUP_PREFIX}_" -c)

if [ ! -z $MINIMUM_BACKUPS ] && [ $MINIMUM_BACKUPS -lt $TOTALBACKUPS ]
then
  /dropbox_uploader.sh -f /config/.dropbox_uploader list | grep "${BACKUP_PREFIX}_" | while read LINE
  do
    # example "LINE":
    # [F] 6688 db.sqlite3_2021-01-02-063033_1609569033.tar.gz"

    # example "BACKUP_FILENAME": (tokenize on default whitespace)
    # db.sqlite3_2021-01-02-063033_1609569033.tar.gz
    BACKUP_FILENAME=$(echo $LINE | awk '{ print $3 }')

    # example db.sqlite3_2021-01-02-063033_1609569033.tar.gz
    # prefix_2021-01-02-063033_1609569033.tar.gz
    # reason if people add underscores to prefix
    BACKFILE_WITHOUTPREFIX=$($BACKUP_FILENAME/${BACKUP_PREFIX}/prefix)

    # example "BACKUP_DATE": (tokenize on _ & -)
    # 2021-01-02
    BACKUP_DATE=$(echo $BACKFILE_WITHOUTPREFIX | awk 'BEGIN { FS = "[_-]" } ; { printf "%s-%s-%s",$2,$3,$4 }')

    # check if integer
    if [[ $BACKUP_DATE =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
    then
      # Seems a valid file
      # Convert date to seconds since epoch
      BACKUP_DATE_SECS=$(date -d $BACKUP_DATE +%s)

      DAYS_DIFF=$(( ($DATE_NOW - $BACKUP_DATE_SECS) / (60*60*24) ))

      if [ "$DAYS_DIFF" -gt "$DELETE_AFTER" ]
      then
        echo "File $BACKUP_FILENAME is $DAYS_DIFF days old (greater than $DELETE_AFTER days). Deleting it."
        /dropbox_uploader.sh -f /config/.dropbox_uploader delete /$BACKUP_FILENAME
      fi
    fi
  done
fi

