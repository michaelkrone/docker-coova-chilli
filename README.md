# wip: CoovaChilly Docker container

* Ubuntu 16.04
* CoovaChilly 1.4 - http://coova.github.io/CoovaChilli/

```
# docker run -ti -P --sysctl net.ipv4.ip_forward=1 --privileged  coova-chilli

docker network create lan
docker network create wan

docker create -it -P --net wan  --name chilli --sysctl net.ipv4.ip_forward=1 --privileged docker-coova-chilli:latest

docker network connect lan chilli

docker start chilli

docker exec -it chilli /bin/bash
```
