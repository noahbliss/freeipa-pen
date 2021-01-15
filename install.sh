#!/usr/bin/env bash

if [ $UID -ne 0 ]; then echo "Run as root or use sudo." exit 1; fi

mkdir -p /etc/passexp
cp mailer.sh /etc/passexp/mailer.sh
cp mailer.conf /etc/passexp/mailer.conf
chmod 600 /etc/passexp/mailer.conf

echo "Files installed to /etc/passexp. Make sure to update mailer.conf. Ensure only root can read mailer.conf."

