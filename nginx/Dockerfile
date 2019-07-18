FROM nginx:stable-alpine

ARG DOMAIN

COPY ./commento.conf /etc/nginx/conf.d/
RUN sed -i "s/__DOMAIN__/$DOMAIN/" /etc/nginx/conf.d/commento.conf

COPY ./bootstrap.sh /

ENTRYPOINT ["/bootstrap.sh"]
