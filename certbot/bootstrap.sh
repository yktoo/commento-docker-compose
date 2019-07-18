#!/bin/sh

trap exit TERM

# Wait until nginx is up and running, up to 10 seconds
wait_for_nginx() {
    echo 'Waiting for nginx...'
    i=0
    while ! nc -z nginx 80 &>/dev/null; do
        sleep 0.5
        [[ $((i++)) -gt 20 ]] && echo "nginx isn't online after 10 seconds, aborting" && exit 4
    done
    echo 'nginx is up and running'
}

# Check vars
[[ -z "$DOMAIN" ]] && echo "Environment variable 'DOMAIN' isn't defined" && exit 2
[[ -z "$EMAIL"  ]] && echo "Environment variable 'EMAIL' isn't defined" && exit 2
TEST="${TEST:-false}"

# Check external mounts
data_dir='/etc/letsencrypt'
www_dir='/var/www/certbot'
[[ ! -d "$data_dir" ]] && echo "Directory $data_dir must be externally mounted"
[[ ! -d "$www_dir"  ]] && echo "Directory $www_dir must be externally mounted"

# If the config/certificates haven't been initialised yet
if [[ ! -e "$data_dir/options-ssl-nginx.conf" ]]; then

    # Copy config over from the initial location
    echo 'Initialising nginx config'
    cp /conf/options-ssl-nginx.conf /conf/ssl-dhparams.pem "$data_dir/"

    # Copy dummy certificates
    mkdir -p "$data_dir/live/$DOMAIN"
    cp /conf/privkey.pem /conf/fullchain.pem "$data_dir/live/$DOMAIN/"

    # Wait for nginx
    wait_for_nginx

    # Remove dummy certificates
    rm -rf "$data_dir/live/$DOMAIN/"

    # Run certbot to validate/renew certificate
    test_arg=
    $TEST && test_arg='--test-cert'
    certbot certonly --webroot -w /var/www/certbot -n -d "$DOMAIN" $test_arg -m "$EMAIL" --rsa-key-size 4096 --agree-tos --force-renewal

    # Reload nginx config
    touch /var/www/certbot/.nginx-reload

# nginx config has been already initialised - just give nginx time to come up
else
    wait_for_nginx
fi

# Run certbot in a loop for renewals
while :; do
    certbot renew
    # Reload nginx config
    touch /var/www/certbot/.nginx-reload
    sleep 12h
done