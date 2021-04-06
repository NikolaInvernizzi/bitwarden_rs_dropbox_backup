#!/bin/bash

# setup dropbox uploader config file
/dropbox_uploader.sh -f /config/.dropbox_uploader info

CONFIGFILE=/config/.dropbox_uploader
if [ ! -f "$CONFIGFILE" ]; 
then
    echo "Setup failed, rerun /setup.sh."
    echo "Setup failed, rerun /setup.sh." >> /logs/bitwarden_backup.log
    echo " " >> /logs/bitwarden_backup.log
    exit 0
fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> /logs/bitwarden_backup.log
echo "Dropbox setup done!" >> /logs/bitwarden_backup.log
echo " " >> /logs/bitwarden_backup.log
/dropbox_uploader.sh -f /config/.dropbox_uploader info >> /logs/bitwarden_backup.log
echo " " >> /logs/bitwarden_backup.log
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> /logs/bitwarden_backup.log
echo " " >> /logs/bitwarden_backup.log

/backup-bitwarden.sh

