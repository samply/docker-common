#!/bin/bash -e
source /scripts/common_entrypoint.sh
### Configure tomcat
## Default environment variables:
: "${TOMCAT_REVERSEPROXY_FQDN:=$FQDN}"
: "${TOMCAT_REVERSEPROXY_PORT:=8080}"
: "${TOMCAT_REVERSEPROXY_SSL:=false}"

## Reverse proxy configuration
sed -e "s|TOMCAT_REVERSEPROXY_FQDN|$TOMCAT_REVERSEPROXY_FQDN|g ; \
	s|TOMCAT_REVERSEPROXY_PORT|$TOMCAT_REVERSEPROXY_PORT|g ; \
	s|TOMCAT_REVERSEPROXY_SSL|$TOMCAT_REVERSEPROXY_SSL|g" \
	/usr/local/tomcat/conf/server.docker.xml > /usr/local/tomcat/conf/server.xml;

if [ "$DEBUG" = 'true' ]; then
  ## Starting tomcat in remote debug mode
	export JPDA_ADDRESS=1099;
	export JPDA_TRANSPORT=dt_socket;
	echo "Info: starting $COMPONENT tomcat with debug mode. Debug port is set to $JPDA_ADDRESS and JPDA_TRANSPORT is set to $JPDA_TRANSPORT";
	exec catalina.sh jpda run;
else
  ## Starting tomcat in productive mode
  echo "Info: starting $COMPONENT tomcat ...";
	exec catalina.sh run;
fi
