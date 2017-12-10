# wip: Freeradius Docker container

```
# docker run -ti -P --sysctl net.ipv4.ip_forward=1 --privileged  docker-freeradius:latest

docker network create lan
docker network create wan

docker create -it -P --net wan  --name radius --sysctl net.ipv4.ip_forward=1 --privileged docker-freeradius:latest

docker network connect lan radius

docker start radius

docker exec -it radius /bin/bash
```
