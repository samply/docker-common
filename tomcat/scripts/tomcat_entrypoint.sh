#!/bin/bash -e
source /scripts/common_entrypoint.sh
### Start tomcat
echo "Info: starting $COMPONENT tomcat ...";
catalina.sh run
