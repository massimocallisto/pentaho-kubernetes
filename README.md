# Pentaho Server on kubernetes
(Work in progress..)

Pentaho Server running on kubernetes. The project also contains a Docker compose running version.
Software tools versions:
* Pentaho Business Analytics CE 9.0
* PostgreSQL 10

## Docker Image Building
The deployment process combine the Docker image creation starting from original Pentaho distribution along with the confd tool (https://github.com/kelseyhightower/confd) required to override environmental variables within the Pentaho xml files.

To keep the image as small as possible (the one provided by kespinosa05 is over 5GB), the docker file uses a multi-stage processing and removes the non-root execution for Pentaho.
We also injected the confd files executed in the `startup.sh` script.

## How to Use
Checkout this project and use the provided `docker-compose.yml` file to start both database (PostgreSQL) and Pentaho Server with:

    docker-compose up -d

You can customize the environmental variables as needed. Currently, `Dockerfile` exposes two system variables only related to PostgreSQL database:

```
...
# Confd to replace file with ENV vars
ENV POSTGRES_HOST somehost
ENV POSTGRES_PORT 6643
...
```

You can change in `docker-compose.yml` the provided variables according to you environment.

## Kubernetes
TODO

## TODO
* Adding support for other Database systems

## Credits
The project takes insipration from https://github.com/kespinosa05/pentaho-server for Docker image creation and this useful guide https://diethardsteiner.github.io/pentaho-server/2018/04/01/Kubernates-and-Pentaho-Server.html for `confd` tool integration.

## License
The project is under GNU General Public License v3.0
