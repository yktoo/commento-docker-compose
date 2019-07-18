#!/bin/sh

trap exit TERM

# Wait for the certificate file to arrive
wait_for_certs() {
    echo 'Waiting for config files from certbot...'
    i=0
    while [[ ! -f /etc/letsencrypt/options-ssl-nginx.conf ]]; do
        sleep 0.5
        [[ $((i++)) -gt 20 ]] && echo 'No files after 10 seconds, aborting' && exit 2
    done
}

# Watches for a "reload flag" (planted by certbot container) file and reloads nginx config once it's there
watch_restart_flag() {
    while :; do
        [[ -f /var/www/certbot/.nginx-reload ]] &&
            rm -f /var/www/certbot/.nginx-reload &&
            echo 'Reloading nginx' &&
            nginx -s reload
        sleep 10
    done
}

# Wait for certbot
wait_for_certs

# Start "reload flag" watcher
watch_restart_flag &

# Run nginx in the foreground
echo 'Starting nginx'
exec nginx -g 'daemon off;'
