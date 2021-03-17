ARG TOMCAT_VERSION="8-jdk8-openjdk-slim"
FROM tomcat:$TOMCAT_VERSION
MAINTAINER Torben Brenner "t.brenner@dkfz-heidelberg.de"
### Environment Variables need to be set at build time
### TODO: this needs to be done on build ...
ONBUILD ARG COMPONENT="test"
ONBUILD ENV COMPONENT=$COMPONENT

### Parameter for user defined mandatory variables. The tomcat image itself should have no mandatory variables.
ONBUILD ARG MANDATORY_VARIABLES=""
ONBUILD ENV MANDATORY_VARIABLES=$MANDATORY_VARIABLES

### This will specify the version to use from https://github.com/samply/docker-common. This can be any tag, branchname or commit hash
ARG COMMON_REPOSITORY_VERSION=develop
LABEL docker.common.version="$COMMON_REPOSITORY_VERSION"

### ADD scripts that will run on container startup
ADD ./tomcat/scripts/tomcat_entrypoint.sh ./scripts/common_entrypoint.sh /docker/

### ADD config files for tomcat configuration. These files will be processed in tomcat_entrypoint.sh
ADD ./tomcat/config/server.reverseproxy.patch /docker/

### Run dos2unix to prevent issues from windows files
RUN apt-get update -y && apt-get install -y \
	patch \
	&& rm -rf /var/lib/apt/lists/*

### Change to user with only www-data permissions
ONBUILD RUN set -x ; \
    adduser --disabled-password --ingroup www-data $COMPONENT; \
    chown -R $COMPONENT:www-data $CATALINA_HOME /docker/ /run/secrets/; \
    chmod -R 755 $CATALINA_HOME /docker/;

ENTRYPOINT ["/docker/tomcat_entrypoint.sh"]
