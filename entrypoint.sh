#!/bin/bash

echo "$MAILNAME" > /etc/mailname
# echo "root: $POSTMASTER" >> /etc/aliases

sed -i "s/{ DOMAINS }/${DOMAINS}/" /etc/exim4/conf.d/main/000_localmacros
sed -i "s/{ mailname }/${MAILNAME}/" /etc/exim4/update-exim4.conf.conf
sed -i "s/{ mailname }/${MAILNAME}/" /etc/exim4/conf.d/main/000_localmacros

sed -i "s/^#?\s*smtp_banner\s*=\s*.*$/smtp_banner = ${MAILNAME} ESMTP Exim \$version_number \$tod_full/" /etc/exim4/conf.d/main/02_exim4-config_options

update-exim4.conf

chown -R Debian-exim /var/spool/exim4
chown -R Debian-exim /var/mail

if [ $? -eq 0 ]; then
  exec "$@"
fi
