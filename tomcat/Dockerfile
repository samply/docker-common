ARG TOMCAT_VERSION="8-jdk8-openjdk-slim"
FROM tomcat:$TOMCAT_VERSION
MAINTAINER Torben Brenner "t.brenner@dkfz-heidelberg.de"
### Environment Variables need to be set at build time
ARG COMPONENT="test"
ENV COMPONENT=$COMPONENT

### Parameter for user defined mandatory variables. The tomcat image itself should have no mandatory variables.
ARG MANDATORY_VARIABLES=""
ENV MANDATORY_VARIABLES=$MANDATORY_VARIABLES

### This either can be specified to local directory, or for use in components as url to raw files: e.g.: https://bitbucket.org/brennert/docker.common/raw/9b8f6b559076a97caec544f7e65f9a2433be5d65
ARG COMMON_REPOSITORY_URN=$(pwd)
ENV COMMON_REPOSITORY_URN=$COMMON_REPOSITORY_URN

### Checksum of the Deployed Artifact
ENV ARTIFACT_SHA512=""
### Extract ARTIFACT to ROOT
### TODO: Support for already extracted artifact
COPY ./*.war $CATALINA_HOME/webapps/
RUN cd $CATALINA_HOME/webapps/ && mv *.war ROOT.war && \
    set ARTIFACT_SHA512=$(sha512sum ./ROOT.war) && \
    mkdir ROOT && cd ROOT && jar xvf ../ROOT.war && rm ../ROOT.war

### ADD scripts that will be run on container startup
ADD $COMMON_REPOSITORY_URN/tomcat/scripts/tomcat_entrypoint.sh /scripts/
ADD $COMMON_REPOSITORY_URN/scripts/common_entrypoint.sh /scripts/
### ADD config files for tomcat configuration. These files will be processed in tomcat_entrypoint.sh
ADD $COMMON_REPOSITORY_URN/tomcat/config/server.reverseproxy.patch $CATALINA_HOME/conf/

### Run dos2unix to prevent issues from windows files
RUN apt-get update -y && apt-get install -y dos2unix patch && apt-get clean && \
    find /scripts/ -type f -print0 | xargs -0 dos2unix && \
    find $CATALINA_HOME/conf/ -type f -print0 | xargs -0 dos2unix && \
    apt-get remove -y dos2unix

### Change to user with only www-data permissions
RUN set -x ; \
    adduser --disabled-password --system --ingroup www-data $COMPONENT; \
    chown -R $COMPONENT:www-data $CATALINA_HOME /scripts/ /run/secrets/; \
    chmod -R 755 $CATALINA_HOME /scripts/;
USER $COMPONENT:www-data

ENTRYPOINT ["/scripts/tomcat_entrypoint.sh"]
