FROM arm32v7/alpine:3.12.6

# newer alpine(s) give error on apk add

# install sqlite, curl, bash (for script)
RUN apk add --no-cache \
    sqlite \
    curl \
    bash \
    openssl \
    dos2unix

# install dropbox uploader script
RUN curl "https://raw.githubusercontent.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh" -o dropbox_uploader.sh && \
    chmod +x dropbox_uploader.sh

# # copy backup script to /
COPY backup-bitwarden.sh /

# # copy entrypoint to /
COPY entrypoint.sh /

# # copy delete older backup script to /
COPY backup-delete.sh /

# # copy setup dropbox script to /
COPY setup.sh /

# # give execution permission to scripts
RUN chmod +x /entrypoint.sh && \
    chmod +x /backup-bitwarden.sh && \
    chmod +x /backup-delete.sh && \
    chmod +x /setup.sh

RUN dos2unix /entrypoint.sh \
            /backup-bitwarden.sh \
            /backup-delete.sh \
            /setup.sh

ENTRYPOINT ["/entrypoint.sh"]
