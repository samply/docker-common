ARG TOMCAT_VERSION="8-jdk8-openjdk-slim"
FROM tomcat:$TOMCAT_VERSION
MAINTAINER Torben Brenner "t.brenner@dkfz-heidelberg.de"
### Environment Variables need to be set at build time
ARG COMPONENT="test"
ENV COMPONENT=$COMPONENT

ARG DEPLOYMENT_CONTEXT="ROOT"
ENV DEPLOYMENT_CONTEXT=$DEPLOYMENT_CONTEXT

ARG MANDATORY_VARIABLES=""
ENV MANDATORY_VARIABLES=$MANDATORY_VARIABLES

### Args only necessary at build time
ARG ARTIFACT_URN="https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war"

### Extract ARTIFACT to DEPLOYMENT_CONTEXT
ADD $ARTIFACT_URN $CATALINA_HOME/webapps/$DEPLOYMENT_CONTEXT.war
RUN cd $CATALINA_HOME/webapps/ && set ARTIFACT_SHA512=$(sha512sum ./$DEPLOYMENT_CONTEXT.war) && mkdir $DEPLOYMENT_CONTEXT && cd $DEPLOYMENT_CONTEXT && jar xvf ../$DEPLOYMENT_CONTEXT.war

### ADD additional scripts and config files needed for component configuration
### TODO: Possibility for additional scripts loaded from other source than docker.common SCRIPTS_URN???
ADD ./scripts/* /scripts/
RUN apt-get update -y && apt-get install -y dos2unix && apt-get clean && \
    find /scripts/ -type f -print0 | xargs -0 dos2unix && \
    apt-get remove -y dos2unix
### TODO: Possibility for additional config file loaded from other source than docker.common CONFIG_URN???
ADD ./config/*.docker.* /tmp/

### Change to user with only www-data permissions
RUN set -x ; \
    adduser --disabled-password --system --ingroup www-data $COMPONENT; \
    chown -R $COMPONENT:www-data $CATALINA_HOME /scripts/ /tmp/; \
    chmod -R 755 $CATALINA_HOME /scripts/ /tmp/;
USER $COMPONENT:www-data

ENTRYPOINT ["/scripts/tomcat_entrypoint.sh"]
