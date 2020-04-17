ARG TOMCAT_VERSION="8-jdk8-openjdk-slim"
FROM tomcat:$TOMCAT_VERSION
MAINTAINER Torben Brenner "t.brenner@dkfz-heidelberg.de"
### Environment Variables need to be set at build time
ARG COMPONENT="test"
ENV COMPONENT=$COMPONENT

ARG DEPLOYMENT_CONTEXT="ROOT"
ENV DEPLOYMENT_CONTEXT=$DEPLOYMENT_CONTEXT

ARG ARTIFACT_URN="https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war"
ENV ARTIFACT_URN=$ARTIFACT_URN

ARG MANDATORY_VARIABLES=""
ENV MANDATORY_VARIABLES=$MANDATORY_VARIABLES

ARG COMMON_REPOSITORY_URL=https://bitbucket.org/brennert/docker.common
ARG COMMIT_HASH=56ee08acc8fded11f8dda050124ef4e8b7107aa6

### Extract ARTIFACT to DEPLOYMENT_CONTEXT
ADD $ARTIFACT_URN $CATALINA_HOME/webapps/$DEPLOYMENT_CONTEXT.war
RUN cd $CATALINA_HOME/webapps/ && set ARTIFACT_SHA512=$(sha512sum ./$DEPLOYMENT_CONTEXT.war) && mkdir $DEPLOYMENT_CONTEXT && cd $DEPLOYMENT_CONTEXT && jar xvf ../$DEPLOYMENT_CONTEXT.war

### TODO: make this link dynamic --> $REPOSITORY_URL and $COMMIT_HASH?
### ADD scripts that will be run on container startup
ADD $COMMON_REPOSITORY_URL/raw/$COMMIT_HASH/tomcat/scripts/tomcat_entrypoint.sh /scripts/
ADD $COMMON_REPOSITORY_URL/raw/$COMMIT_HASH/scripts/common_entrypoint.sh /scripts/
### ADD config files for tomcat configuration. These files will be processed in tomcat_entrypoint.sh
ADD $COMMON_REPOSITORY_URL/raw/$COMMIT_HASH/tomcat/config/server.docker.xml $CATALINA_HOME/conf/

### Run dos2unix to prevent issues from windows files
RUN apt-get update -y && apt-get install -y dos2unix && apt-get clean && \
    find /scripts/ -type f -print0 | xargs -0 dos2unix && \
    find $CATALINA_HOME/conf/ -type f -print0 | xargs -0 dos2unix && \
    apt-get remove -y dos2unix

### Change to user with only www-data permissions
RUN set -x ; \
    adduser --disabled-password --system --ingroup www-data $COMPONENT; \
    chown -R $COMPONENT:www-data $CATALINA_HOME /scripts/; \
    chmod -R 755 $CATALINA_HOME /scripts/;
USER $COMPONENT:www-data

ENTRYPOINT ["/scripts/tomcat_entrypoint.sh"]
