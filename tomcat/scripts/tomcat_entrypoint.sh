#!/bin/bash -e
source /scripts/common_entrypoint.sh
### Configure tomcat

if [ "$DEBUG" = 'true' ]; then
	export JPDA_ADDRESS=1099;
	export JPDA_TRANSPORT=dt_socket;
	echo "Info: starting $COMPONENT tomcat with debug mode. Debug port is set to $JPDA_ADDRESS and JPDA_TRANSPORT is set to $JPDA_TRANSPORT";
	exec catalina.sh jpda run;
else
  echo "Info: starting $COMPONENT tomcat ...";
	exec catalina.sh run;
fi
