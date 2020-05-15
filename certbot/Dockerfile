#=======================================================================================================================
# Dockerfile for automated SSL certificate generation with Let's Encrypt/certbot
# Environment variables:
#     DOMAIN  Mandatory. Target domain, e.g. 'example.com'
#     EMAIL   Mandatory. Contact email address for certificate renewal notifications
#     TEST    Optional, true/false. Whether to run certbot against a test server. Default is false
#=======================================================================================================================
FROM certbot/certbot:v0.29.1

COPY bootstrap.sh /

RUN \
    # Install required packages
    apk add --no-cache curl && \
    # Download initial TLS params recommended by Let's Encrypt
    mkdir -p /conf && \
    curl -fsSL https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "/conf/options-ssl-nginx.conf" && \
    curl -fsSL https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "/conf/ssl-dhparams.pem" && \
    # Create a dummy certificate for nginx
    openssl req -x509 -nodes -newkey rsa:1024 -days 1 -keyout '/conf/privkey.pem' -out '/conf/fullchain.pem' -subj '/CN=localhost' && \
    # Cleanup
    apk del curl

STOPSIGNAL SIGKILL

ENTRYPOINT ["/bootstrap.sh"]
