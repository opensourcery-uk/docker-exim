FROM opensourcery/debian:buster-slim
LABEL maintainer "open.source@opensourcery.uk"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get dist-upgrade -y \
 && apt-get install -y exim4-daemon-heavy spf-tools-perl \
 && apt-get install -y ca-certificates \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*

RUN sed -i 's/#\?[ tab]*spamd_address[ tab]\+=[ tab]\+.\+$/spamd_address = rspamd 11333 variant=rspamd/' /etc/exim4/conf.d/main/02_exim4-config_options \
 && sed -i 's/#\?[ tab]*av_scanner[ tab]=[ tab]\+.\+$/av_scanner = clamd:clamav 3310/' /etc/exim4/conf.d/main/02_exim4-config_options \
 && sed -i 's/^\([^#\n].*\)/#\1/' /etc/exim4/conf.d/auth/30_exim4-config_examples \
 && mkdir /etc/exim4/conf.d/local

ADD update-exim4.conf.conf.template /etc/exim4/update-exim4.conf.conf

ADD main__000_localmacros /etc/exim4/conf.d/main/000_localmacros
ADD main__10_exim4-config_daemon_smtp_ports /etc/exim4/conf.d/main/10_exim4-config_daemon_smtp_ports

ADD auth__35_exim4-config_pam-auth /etc/exim4/conf.d/auth/35_exim4-config_pam-auth

ADD local__acl_exim4-config_check-data-local /etc/exim4/conf.d/local/acl_exim4-config_check-data-local
ADD local__acl_exim4-config_check-rcpt-local /etc/exim4/conf.d/local/acl_exim4-config_check-rcpt-local

ADD entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

EXPOSE 2525 587

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/exim4", "-bd", "-d+all", "-v", "-q30m"]
