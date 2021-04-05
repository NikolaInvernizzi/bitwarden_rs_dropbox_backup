#!/bin/bash

# setup dropbox uploader config file
/dropbox_uploader.sh -f /config/.dropbox_uploader info

echo "Dropbox setup done" >> /logs/bitwarden_backup.log
/dropbox_uploader.sh -f /config/.dropbox_uploader info >> /logs/bitwarden_backup.log

/backup-bitwarden.sh