ARG TOMCAT_VERSION="9-jdk17-temurin-focal"
FROM tomcat:$TOMCAT_VERSION
MAINTAINER Torben Brenner "t.brenner@dkfz-heidelberg.de"
### Environment Variables need to be set at build time
### TODO: this needs to be done on build ...
ONBUILD ARG COMPONENT="test"
ONBUILD ENV COMPONENT=$COMPONENT

### Parameter for user defined mandatory variables. The tomcat image itself should have no mandatory variables.
ONBUILD ARG MANDATORY_VARIABLES=""
ONBUILD ENV MANDATORY_VARIABLES=$MANDATORY_VARIABLES

### ADD scripts that will run on container startup
### ADD config files for tomcat configuration. These files will be processed in tomcat_entrypoint.sh
ADD ./tomcat/scripts/tomcat_entrypoint.sh ./tomcat/config/server.reverseproxy.patch ./tomcat/config/server.relaxedQueryChars.patch ./scripts/common_entrypoint.sh ./scripts/proxify.sh /docker/

### Run dos2unix to prevent issues from windows files
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
	patch proxychains4 \
	&& rm -rf /var/lib/apt/lists/*

RUN sed -i 's/^# localnet /localnet /;s/^socks.*$/http PROXYIP PROXYPORT/' /etc/proxychains4.conf

### Change to user with only www-data permissions
ONBUILD RUN set -x ; \
    adduser --disabled-password --ingroup www-data $COMPONENT; \
    chown -R $COMPONENT:www-data $CATALINA_HOME /docker/ /usr/local/share/ca-certificates/ $JAVA_HOME/lib/security/cacerts /etc/ssl/certs/ /run/secrets/; \
    mkdir /docker/custom-certs/; \
    chmod -R 755 $CATALINA_HOME /docker/;

ONBUILD USER $COMPONENT
ENTRYPOINT ["/docker/tomcat_entrypoint.sh"]
