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

### This will specify the version to use from https://bitbucket.org/brennert/docker.common. This can be any tag, branchname or commit hash
ARG COMMON_REPOSITORY_VERSION=develop
LABEL docker.common.version="$COMMON_REPOSITORY_VERSION"

### ADD scripts that will run on container startup
ADD ./tomcat/scripts/tomcat_entrypoint.sh /scripts/
ADD ./scripts/common_entrypoint.sh /scripts/
### ADD config files for tomcat configuration. These files will be processed in tomcat_entrypoint.sh
ADD ./tomcat/config/server.reverseproxy.patch $CATALINA_HOME/conf/

### Run dos2unix to prevent issues from windows files
RUN apt-get update -y && apt-get install -y dos2unix patch && apt-get clean && \
    find /scripts/ -type f -print0 | xargs -0 dos2unix && \
    find $CATALINA_HOME/conf/ -type f -print0 | xargs -0 dos2unix && \
    apt-get remove -y dos2unix

### ONBUILD Copy build context to ROOT
### This will also happen in images that use this image in their FROM instruction
ONBUILD COPY . $CATALINA_HOME/webapps/ROOT/

### Change to user with only www-data permissions
ONBUILD RUN set -x ; \
    adduser --disabled-password --system --ingroup www-data $COMPONENT; \
    chown -R $COMPONENT:www-data $CATALINA_HOME /scripts/ /run/secrets/ /docker/; \
    chmod -R 755 $CATALINA_HOME /scripts/;
ONBUILD USER $COMPONENT:www-data

ENTRYPOINT ["/scripts/tomcat_entrypoint.sh"]
