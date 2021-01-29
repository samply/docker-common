# docker.common

docker.common is a project to consolidate build processes of the docker images for different components. The main focus is to
keep components unaware of how their docker image is build. In the ideal case it should be possible to create a docker image for
a component, without adding any file to the components repository.

## Installation

TODO: Is there any installation if you don't need to download this repository for usage?

### Prequeresites
You will need docker to create docker images with the files from this repository :)

## Usage

In this section the usage of the different common images (subdirectories in this repository besides script directory) will be described.

> Note: In the next section commands often refer to <common_repository_url>. 
>       This can be replaced by a link like this: https://bitbucket.org/brennert/docker.common/raw/11df911fc47f212d89d6bf4ff92434cf3380fdbc
### Builders
Builders are needed to build the artifacts, that will be deployed in the final component image.
#### maven-git
To build a war file from component repository with maven-git, you will first need to prepare a builder image:
```shell script
curl <common_repository_url>/maven-git/Dockerfile | docker build -t maven-git-builder -
```
> Note: The maven-git-builder supports a build arg for selection of maven image: MAVEN_VERSION

With this new build builder image, you can build your components war file (Assuming you are currently at the root of your components repository):
```shell script
docker run -it --rm --name component-build -v /$(pwd)/://usr/src/build/ -w //usr/src/build/ maven-git-builder mvn clean install;
```
> Note: If you want to use your local maven repository and settings, you can pass them as a volume (assuming your repository and maven configuration reside in $HOME/.m2):
>       -v /$HOME/.m2/://root/.m2

### Final Images
With these images you can build your component image. They need a artifact(e.g. an exploded WAR file) from you. You can either generate artifacts yourself or use a builder from this repository.
#### tomcat - Outdated, needs update
The docker common image is available on docker hub at [https://hub.docker.com/r/torbenbrenner/tomcat.common](https://hub.docker.com/r/torbenbrenner/tomcat.common)
The image defines different onbuild steps, so you can import it and get the full functionality of docker.common.
You can use it like:
```Dockerfile
FROM torbenbrenner/tomcat.common:latest
### Additional configuration like unpacking a war file (the image normally uses exploded wars)
# MAINTAINER you
### You can set default values for your environment variables
```

#### Configuration of component image
##### Defining Environment Variables available for the user
Then building an image, you would normally like to give your users access to different component specific environment variables like 
a password that is needed to login in to your components ui. These passwords normally are part of configuration files used by your component. 
For example component test could need the config file "test.ui.conf" which looks like:
```properties
admin.user.name=sampleUser
admin.user.pasword=changeMePlease
```
The easiest way to define environment variables for this with docker.common is to supply a template in your repository classes directory:
e.g test.ui.docker.conf
> Note: the .docker. marks a template file as template file. This is possible with all kinds of files e.g yml,xml,properties
```properties
admin.user.name=ADMIN_USER_NAME
admin.user.password=ADMIN_USER_PASSWORD
```
Then you now build an image with this repository you can use following environment variables on your image:

|ENVIRONMENT_VARIABLE|DEFAULT|
|--------------------|-------|
|ADMIN_USER_NAME|ADMIN_USER_NAME|
|ADMIN_USER_PASSWORD|ADMIN_USER_PASSWORD|

Users of the image can also pass secrets to the container running the image:
```yaml
services:
  testcomponent:
    image: test-image
    secrets:
      - ADMIN_USER_NAME_SECRET
      - ADMIN_USER_PASSWORD_SECRET
secrets:
  ADMIN_USER_NAME_SECRET:
    external: true
  ADMIN_USER_PASSWORD_SECRET:
    external: true
```

##### Defining Mandatory Variables
Maybe you want users to always define a password then using the image. For this case the build arg "MANDATORY_VARIABLES" can be used.
You can specify the needed Environment Variables in a List separated by spaces: 
e.g. ```--build-arg MANDATORY_VARIABLES="IMPORTANT_PASSWORD REALLY_IMPORTANT_PASSWORD"``` 

##### Adding new template files without changing the repository
At the beginning, it was necessary to add an template file to the components repository. Starting from COMMIT (TODO: Insert commit) it is 
possible, to add template files at startup of the container.
> Note: It is necessary to use docker-compose/docker stack features for this.

In the example of how to define environment variables, we used test.ui.docker.conf and added it to the component repository to give
users access to ADMIN_USER_NAME and ADMIN_USER_PASSWORD environment variables. With docker-compose we can use the secrets/config feature
to pass a template file at runtime:
```yaml
services:
  testcomponent:
    image: test-image
    secrets:
      - test.ui.docker.conf
secrets:
  test.ui.docker.conf:
    file: test.ui.docker.conf 
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
# Changed localRepositoryLocations in Maven Settings results in docker error
Then you change the location of your local maven repository, it will result in issues then mounting it to docker container.
The container will try to access the path you specified in your settings.xml and will most likely not find it. 
