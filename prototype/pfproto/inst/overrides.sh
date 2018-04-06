#!/bin/bash

chown -R cbaker:cbaker /home/cbaker/*
chmod +x /home/cbaker/pfproto/inst/cron/daily-download.sh

# override password set during docker build
PASSWORD=$(cat /run/secrets/rstudio-cbaker-password)
echo "cbaker:$PASSWORD" | chpasswd
