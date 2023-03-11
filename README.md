**WARNING:**

Commento is discontinued and not getting updates anymore. I recommend switching to [Comentario](https://comentario.app/), a fork of Commento that I'm actively developing.

---

# Auto-deployable Commento server

This is a sample repository containing a self-sufficient [Commento](https://commento.io/) instance running on [Docker Compose](https://docs.docker.com/compose/) and using free auto-renewable SSL/TLS certificates provided by [Let's Encrypt](https://letsencrypt.org/).

💡 **Curious about how this works? Read a [detailed explanation here](https://yktoo.solutions/blog/2019/07/28-self-hosting-commento-with-docker-compose/).**

Using this as a starting point, you can set up a self-hosted Commento instance in a matter of minutes.

## Prerequisites

1. You own a domain and a Linux server
2. You have `root` shell access to the server

## Step-by-step instructions

1. Install [Docker](https://docs.docker.com/install/) and [docker-compose](https://docs.docker.com/compose/install/)
2. Clone the project code to `/opt/commento`, for example:
    ```bash
    sudo git clone https://github.com/yktoo/commento-docker-compose.git /opt/commento
    ```
3. Edit `/opt/commento/docker-compose.yml` and update the environment variable values appropriately
4. Recommended: pre-build and pre-pull the required images:
    ```bash
    cd /opt/commento
    docker-compose -p commento pull
    docker-compose -p commento build
    ```
5. Create systemd service symlink, reload the daemon, enable and start the service:
    ```bash
    sudo ln -s /opt/commento/etc/commento.service /etc/systemd/system/commento.service
    sudo systemctl daemon-reload
    sudo systemctl enable commento.service
    sudo systemctl start commento.service
    ```
6. Check the service health with `systemctl status commento.service`
7. Recommended: check in your changes to a new git repository for future use

## Cleaning up

To stop and clean containers up manually (comments and SSL/TLD certificates are always retained):

```bash
cd /opt/commento
docker-compose -p commento down -v
```

## Upgrading

To rebuild the Docker images, for example if you want to upgrade to a newer version of Commento/PostgreSQL/Nginx:
```bash
cd /opt/commento
docker-compose -p commento pull
docker-compose -p commento build
# Restart the service
sudo systemctl restart commento.service
```

## Backing up

To back up the database, the easiest way is to make a dump of the `commento` database.

First, set up a passwordless login to your server using public key authentication.

Then you can export the entire `commento` database using the command:

```bash
ssh YOUR_SERVER_HOST docker exec -t commento_postgres_1 pg_dump -U postgres -d commento > /path/to/dump.sql
```
