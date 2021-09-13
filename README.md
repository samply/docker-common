# Docker Common

The main focus of this Project is to build base images for developers that handle common deployment tasks, e.g. environment variables for configuring tomcat for deployment behind a reverse proxy.

## Contents
Currently, this repository provides implementation for following images:
- [samply/tomcat-common](https://hub.docker.com/r/samply/tomcat-common)

## Prequeresites
- [Docker Community Engine](https://docs.docker.com/engine/install/)

## Features
### Generic Implementation for Replacing Environment Variables in Template Files
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

### Automatic Docker Secret Support
Secrets passed to the container inside the "/run/secrets/" directory will automatically cause the entrypoint script to set the related environment variables value.
E.g. passing secrets for the environment variables from the previous section would look like this
```yaml
services:
  testcomponent:
    image: <your-final-image>
    secrets:
      - ADMIN_USER_NAME_SECRET
      - ADMIN_USER_PASSWORD_SECRET
secrets:
  ADMIN_USER_NAME_SECRET:
    external: true
  ADMIN_USER_PASSWORD_SECRET:
    external: true
```

### Configuration Templates at End User Level
Not only the image creator has the possibility to define environment variables and secrets inside the template files. The user of the final image can pass their own configuration files at specified endpoints.
E.g. 
```yaml
services:
  testcomponent:
    image: <your-final-image>
    secrets:
      - test.ui.docker.conf
secrets:
  test.ui.docker.conf:
    file: test.ui.docker.conf 
```

### Environment Variables available for all Images
There are some variables, like the proxy configuration, that are likely for usage in every image. Because of this docker common will by default search for following variables:

|Variable|Description|
|--------|-----------|
|HTTP_PROXY_URL|The url of a http proxy server, eg. proxy.example.de:8080| 
|HTTP_PROXY_USERNAME|The user used for authentication with http proxy server| 
|HTTP_PROXY_PASSWORD|The password used for authentication with http proxy server| 
|HTTPS_PROXY_URL|The host of a https proxy server, eg. proxy.example.de:8080| 
|HTTPS_PROXY_USERNAME|The user used for authentication with https proxy server| 
|HTTPS_PROXY_PASSWORD|The password used for authentication with https proxy server| 
|NO_PROXY_HOSTS|The hosts for which the proxy should not be used|

> Note: The proxy variables will be used for additionally defining http_proxy and https_proxy environment variables.

### Defining Mandatory Variables
Maybe you want users to always define a password then using the image. For this case the build arg "MANDATORY_VARIABLES" can be used.
You can specify the needed Environment Variables in a List separated by spaces: 
e.g. ```--build-arg MANDATORY_VARIABLES="IMPORTANT_PASSWORD REALLY_IMPORTANT_PASSWORD"``` 

### Defining Default Values
In your components Dockerfile you can set default values for variables by using the "ENV" keyword
e.g. ```ENV EXAMPLE_PASSWORD=pleaseChangeMe```

## Usage
This section provides examples on how to use the different images provided by this repository.

### tomcat-common
You can use it like this:
``` Dockerfile
ARG TOMCAT_COMMON_VERSION=latest
FROM alpine:latest as extract
RUN apk add --no-cache unzip
ADD target/<YourPackageName>.war ./<YourPackageName>.war
RUN mkdir -p /extracted && \
       unzip ./<YourPackageName> -d /extracted
FROM samply/tomcat-common:${TOMCAT_COMMON_VERSION}
MAINTAINER <m.mustermann@example.com>
ARG COMPONENT=example
ENV COMPONENT=${COMPONENT}
# You can set define mandatory variables (separated with spaces). Starting the container without these will fail.
ENV MANDATORY_VARIABLES="REALLY_IMPORTANT_VARIABLE"
# You can set default values for your environment variables
ENV EXAMPLE_LOG_LEVEL="info"
# Finally copy the artifact from the extract stage
COPY --chown="example:www-data" --from=extract ./extracted/ $CATALINA_HOME/webapps/ROOT/
```

Assuming you placed the Dockerfile at the root of your repository (e.g. where your pom.xml is located), you can now build your image with

``` shell
docker build -t your-final-image --build-arg COMPONENT=example .
```

The resulting image will only handle environment variables starting with the prefix "EXAMPLE_". 
#### Additional Environment Variables in samply/tomcat-common
## Known Issues
For a list of currently known issues please refer to [Known Issues](https://github.com/othneildrew/Best-README-Template/issues)

## License

Copyright 2019 - 2021 The Samply Community

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
