# BitWarden_RS Dropbox Nightly Backup for a RaspberryPi  
80% based on https://github.com/shivpatel/bitwarden_rs_dropbox_backup/  
(not forked because it was private repo first)  
  
    
This image takes a nightly (default at 1AM UTC) automated backup of your Bitwarden_rs database and attachments.  
The database and the attachments are encrypted with a given first encryption key and than put in a tar to be uploaded to dropbox after.  
  
**Note:** Encrypting BitWarden backups is not required since the data is already encrypted with user master passwords. We've added this for good practice and added obfuscation should your Dropbox account get compromised.  
  
**IMPORTANT: Make sure you have at least one personal device (e.g. laptop) connected to Dropbox and syncing files locally. This will save you in the event Bitwarden goes down and your Dropbox account login was stored in Bitwarden!!!**  

## How to Use  
It's highly recommend you run via the `docker-compose.yml` provided with portainer. (since it was made this way)  

### setup the docker-compose.yml  
Edit the docker-compose.yml:  
`image`: the current version of the docker-file is: `0.3`  
`restart`: Always, put it on always if you want the container to start making backups after a reboot.  
`volumes`:  
- Volume mount the `./home/XXXX/bitwarden` folder your bitwarden_rs container uses.  
- Volume mount the `./home/XXXX/bitwarden-dropbox-backup/config` folder that will contain the Dropbox Uploader configuration (Dropbox app key, secret and refresh token). See next steps for more details. It's important this volume is mounted so you don't have to redo the `initial run image` step every restart!  
- Volume mount the `./home/XXXX/backups` folder to a folder where you want to keep your local backups.  
`environment`:  
- `BACKUP_PREFIX`, default: `BitwardenBackup`, The prefix for your backup files.  
- `BACKUP_ENCRYPTION_KEY`, default: none, This is for added protection and will be needed when decrypting your backups. Pick a secure passphrase and keep it somewhere safe.  
- `DELETE_AFTER`, default: `10`, this is used to delete old backups after `X` many days. This job is executed with each backup cron job run.  
- `KEEP_LOCAL_BACKUPS`, default: `1`, Variable to tell the script to keep local backups or not; `0` or `1`  
- `CRON_EXPRESSION`, default: `0 1 * * *`, the cron expression to take your backups at. **The image runs default in UTC.**  

### setup Dropbox  
1. Open the following URL in your Browser, and log in using your account: https://www.dropbox.com/developers/apps  
2. Click on "Create App", then select "Choose an API: Scoped Access"  
3. Choose the type of access you need: "App folder"  
4. Enter the "App Name" that you prefer (e.g. MyVaultBackups); must be unique  
5. Now, click on the "Create App" button.  
6. Now the new configuration is opened, switch to tab "permissions" and check "files.metadata.read/write" and "files.content.read/write"  
7. Now, click on the "Submit" button.  
8. Once your app is created, you can find your "App key" and "App secret" in the "Settings" tab.  
  
### Initial run image  
1. Copy the docker-compose.yml in a `portainer` stack   
    - or use `docker-compose up` in the folder where you have the file and run the stack/command  
2. Use portainer to connect to container `stackname`_`bitwarden_dropbox_backup`_1 (click container console and connect using bash)   
    - or use the command `docker exec -it bitwarden_dropbox_backup /bin/bash`  
3. Once in the terminal from the container run: `/setup.sh` and follow the steps in the terminal. **Be carefull with copy-pasting**  
    - It will ask for the "App Key" first.  
    - Secondly, it will ask the "App Secret".  
    - After filling the app secret you will be provided with a link, visit the link and follow the instructions and you will be provided and a "confirmation" key.  
    - Fill in the "confirmation" key into the terminal.  
    - **Confirm that everything was correctly copied: `App Key/Secret` and `Confirmation Key`**  
    - An initial backup will be taken if everything was done correctly.  
    - Done.  
4. Use /logs/bitwarden_backup.log to check if the initial backup was taken and for extra logs about the dropbox link that was setup.  
5. You can now exit the terminal and the backups will now be taken according to your cron expression.  
  
## usefull links  
Check your cron expression https://crontab.guru/  
Check timezones for cron expression: https://www.thetimezoneconverter.com/  
  
## Restoring a backup to BitWarden_rs  
### Decrypting Backup  
When running the command below it will ask for the encryption key you have in your docker-compose.yml.  
The `my-folder` has to exist for the command to work, use `.` to decrypt in current folder.  
Decrypt command:  
`openssl enc -d -aes256 -salt -pbkdf2 -in mybackup.tar.gz | tar xz --strip-components=1 -C my-folder`  
  
### Link decrypted data to bitwarden  
Copy the files in the bitwarden_rs mount, turn the Bitwarden container off first.  
Or  
Volume mount the decrypted folder to your bitwarden_rs container.  
  
Done!  
