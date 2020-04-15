# docker.common

docker.common is TODO: Description

### Installation

TODO: 

### Usage

To use the tomcat base image for any component:
```shell script
docker build -t component:latest -f- <component_repository> < tomcat/Dockerfile
```

Example using tomcat example WAR file
```shell script
docker build -t component:latest .
```

Example from [docker bestpractises](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#pipe-dockerfile-through-stdin):
```shell script
docker build -t myimage:latest -f- https://github.com/docker-library/hello-world.git <<EOF
FROM busybox
COPY hello.c .
EOF
```

### Contributing
Pull requests are welcome. TODO:

Please make sure to update tests as appropriate.

TODO: License
