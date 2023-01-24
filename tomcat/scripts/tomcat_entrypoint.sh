#!/bin/bash -e
source /docker/common_entrypoint.sh
### Configure tomcat
## default environment
: "${TOMCAT_REVERSEPROXY_SSL:=false}"
## Reverse proxy configuration

### Move files from ROOT to a different deployment context
if [ -n "$DEPLOYMENT_CONTEXT" ]; then
  echo "Info: Changing deployment context of application from ROOT to $DEPLOYMENT_CONTEXT";
  if [ -d "$CATALINA_HOME/webapps/$DEPLOYMENT_CONTEXT" ]; then
    echo "Error: The directory $CATALINA_HOME/webapps/$DEPLOYMENT_CONTEXT already exists. Aborting startup!";
    exit 17;
  fi
  mkdir -p "$CATALINA_HOME/webapps/$DEPLOYMENT_CONTEXT";
  mv "$CATALINA_HOME/webapps/ROOT/"* "$CATALINA_HOME/webapps/$DEPLOYMENT_CONTEXT";
fi

if [ -n "$TOMCAT_REVERSEPROXY_FQDN" ]; then
  echo "Info: Configuring reverse proxy for URL $TOMCAT_REVERSEPROXY_FQDN";
  mv $CATALINA_HOME/conf/server.xml $CATALINA_HOME/conf/server.xml.ori;
  ## Apply add reversproxy configuration to
  echo "Info: applying /docker/server.reverseproxy.patch on $CATALINA_HOME/conf/server.xml"
  patch -i /docker/server.reverseproxy.patch -o $CATALINA_HOME/conf/server.xml $CATALINA_HOME/conf/server.xml.ori
  case "$TOMCAT_REVERSEPROXY_SSL" in
    true)
      : "${TOMCAT_REVERSEPROXY_PORT:=443}"
      TOMCAT_REVERSEPROXY_SCHEME=https
      ;;
    false)
      : "${TOMCAT_REVERSEPROXY_PORT:=80}"
      TOMCAT_REVERSEPROXY_SCHEME=http
      ;;
    *)
      echo "Error: Please set TOMCAT_REVERSEPROXY_SSL to either true or false."
      exit 1
  esac
  echo "Info: Applying configuration for ReverseProxy with settings: TOMCAT_REVERSEPROXY_FQDN=$TOMCAT_REVERSEPROXY_FQDN TOMCAT_REVERSEPROXY_PORT=$TOMCAT_REVERSEPROXY_PORT TOMCAT_REVERSEPROXY_SSL=$TOMCAT_REVERSEPROXY_SSL"
  sed -i -e "s|TOMCAT_REVERSEPROXY_FQDN|$TOMCAT_REVERSEPROXY_FQDN|g ; \
  	s|TOMCAT_REVERSEPROXY_SCHEME|$TOMCAT_REVERSEPROXY_SCHEME|g ; \
  	s|TOMCAT_REVERSEPROXY_PORT|$TOMCAT_REVERSEPROXY_PORT|g ; \
  	s|TOMCAT_REVERSEPROXY_SSL|$TOMCAT_REVERSEPROXY_SSL|g" \
  	$CATALINA_HOME/conf/server.xml;
  chown -R $COMPONENT:www-data $CATALINA_HOME/conf/server.xml;
  echo "Info: ReverseProxy configuration is finished"
fi

if [ -n "$RELAXED_QUERY_CHARS" ]; then
    mv $CATALINA_HOME/conf/server.xml $CATALINA_HOME/conf/server.xml.ori;
    echo "Info: applying /docker/server.relaxedQueryChars.patch on $CATALINA_HOME/conf/server.xml"
    patch -i /docker/server.relaxedQueryChars.patch -o $CATALINA_HOME/conf/server.xml $CATALINA_HOME/conf/server.xml.ori
    sed -i -e "s|RELAXED_QUERY_CHARS|$RELAXED_QUERY_CHARS|g" $CATALINA_HOME/conf/server.xml;
    chown -R $COMPONENT:www-data $CATALINA_HOME/conf/server.xml;
fi

# SSL Certs
if [ "$(ls -A /docker/custom-certs/)" ]; then
	echo "Info: Found custom-certs. Now starting import of certs:"
  castore="$JAVA_HOME/jre/lib/security/cacerts"
	for file in /docker/custom-certs/*; do
		cp -v $file /usr/local/share/ca-certificates/$(basename $file).crt
    # Import the certificate using keytool to ensure import even on images that are not debian based
    random=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1);
    echo "Info: Importing $file into $castore as $random";
    keytool -importcert -file "$file" -keystore "$castore" --storepass "changeit" -alias "$random" -noprompt;
	done
	update-ca-certificates || (echo -e "\nError: The system has REJECTED one of the certificates:"; ls -l /docker/custom-certs/*; echo "Make sure that ALL of the certificates are valid."; exit 1)
	echo "Info: Successfully imported custom-certs."
fi

if [ "$DEBUG" = 'true' ]; then
  ## Starting tomcat in remote debug mode
	export JPDA_ADDRESS=*:1099;
	export JPDA_TRANSPORT=dt_socket;
	echo "Info: starting $COMPONENT tomcat with debug mode. Debug port is set to $JPDA_ADDRESS and JPDA_TRANSPORT is set to $JPDA_TRANSPORT";
	exec /docker/proxify.sh catalina.sh jpda run;
else
  ## Starting tomcat in productive mode
  echo "Info: starting $COMPONENT tomcat ...";
	exec /docker/proxify.sh catalina.sh run;
fi
