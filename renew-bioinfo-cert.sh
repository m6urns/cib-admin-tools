#!/usr/bin/env bash

# Renew the cert
certbot renew --force-renewal

# Concat the certs together, and place them in the haproxy directory
bash -c "cat /etc/letsencrypt/live/bioinfocore.usu.edu/fullchain.pem /etc/letsencrypt/live/bioinfocore.usu.edu/privkey.pem > /etc/ssl/certs/haproxy/haproxy.le/haproxy.le.pem"

# Restart haproxy
systemctl restart haproxy

# Installed in root crontab
# 0 0 1 * * bash /home/dock_user/cib-admin-tools/renew-bioinfo-cert.sh

