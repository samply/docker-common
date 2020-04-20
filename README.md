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

### Known Issues
# Dockerignore in Repositories will be used
Passing the repository as build context can lead to issues with building the specific repository.
For example using https://code.mitro.dkfz.de/scm/auth/samply.auth.webapp.git#develop in the -r
option will lead to failing of the maven build with message maven goal not defined. The reason for
this is, that the repository will be copied to build context, but docker checks .dockerignore in the
context before copying everything. Pom is excluded by .dockerignore in this specific case.
