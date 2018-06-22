# hajekjnet-php
Custom PHP runtime image used on my personal server.

## Introduction
This image is a runtime image for hosting PHP workloads on a virtual machine in Docker. This image is likely to be accompanied with a MySQL container. The major point of this image is to replicate [WEDOS](https://wedos.cz) hosting setup, where multiple sites are hosted within the same image.

## Installation
1. Install Docker on the target machine
1. Setup Nginx as a reverse proxy, Let's Encrypt, virtual hosts etc.
1. Execute following command: `docker run ...` 
