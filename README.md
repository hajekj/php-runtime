# hajekjnet-php
Custom PHP runtime image used on my personal server.

## Introduction
This image is a runtime image for hosting PHP workloads on a virtual machine in Docker. This image is likely to be accompanied with a MySQL container. The major point of this image is to replicate [WEDOS](https://wedos.cz) hosting setup, where multiple sites are hosted within the same image while persisting the feel of Azure's App Service on Linux.

## Installation
1. Install Docker on the target machine
1. Setup Nginx as a reverse proxy, Let's Encrypt, virtual hosts etc.
1. Execute following command: `docker run ...` (see below)

## Volume Mounting
In order to be able to use persistent data, use of volume mounting is expected. The data should be mounted in _/home/_ directory.

The folder structure should be following:
```
/home/ - Mounted root
/home/LogFiles/ - Folder with all logs
/home/site/ - Website related files, can contain php.ini and such
/home/site/wwwroot - Application root which Apache points to
```
The real storage is likely to be `/var/hosting/storage/<container_name>` on the underlying instance.

## Server Setup
1. [Install Nginx + Let's Encrypt](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04)
1. [Install Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/)

### Hosting Setup
#### Network
[More info](https://docs.docker.com/network/bridge/#connect-a-container-to-a-user-defined-bridge) on networking in Docker.
```
docker network create network-1
```
Add existing resource network:
```
docker network connect network-1 mysql-1
```
#### MySQL
```
docker run --name mysql-1 --network network-1 --publish 3306:3306 -v /var/hosting/mysql/1:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:5.7
```
#### PHP
```
docker run --name php-1 --network network-1 --publish 62001:8080 -v /var/hosting/storage/1:/home -d hajekj/hajekjnet-php:latest
```
#### Nginx Virtual Host
```

```
