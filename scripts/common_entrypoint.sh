#!/bin/bash -e
echo "Info: executing common_entrypoint.sh";
### TODO: How can users of docker common specify default values?
### Process docker secrets
if [ -d "/run/secrets" ]; then
  for file in "/run/secrets/"*; do
    if [[ "$file" == *"_secret" || "$file" == *"_SECRET" ]] ; then
      echo "Info: Found secret file: $file";
      envName=$(echo "$file" | tr '[:lower:]' '[:upper:]' | sed -e "s|/RUN/SECRETS/||" -e "s|_SECRET||");
      echo "Info: now writing content of $file to $envName";
      eval export "$envName"="$(cat $file)";
    fi
  done
fi

MISSING_VARS=""

## Check for missing variables
echo "Info: Checking if all mandatory variables are specified"
for VAR in $MANDATORY_VARIABLES; do
  if [ -z "${!VAR}" ]; then
    MISSING_VARS+="$VAR "
  fi
done

if [ -n "$MISSING_VARS" ]; then
  echo "Error: Mandatory variables not defined (see documentation): $MISSING_VARS";
  exit 1;
fi

### Process config files passed as docker config
echo "Info: Checking for user defined configs in /"
for templateFilename in /*; do
  if [[ $templateFilename == *".docker."* ]]; then
    echo "Info: Found template $templateFilename. Copy to $CATALINA_HOME/webapps/ROOT/WEB-INF/classes/";
    cp "$templateFilename" "$CATALINA_HOME/webapps/ROOT/WEB-INF/classes/${templateFilename//\/run\/secrets\/}";
  fi
done

### Process config files passed as docker secret
echo "Info: Checking for user defined configs in /run/secrets/"
for templateFilename in /run/secrets/*; do
  if [[ $templateFilename == *".docker."* ]]; then
    echo "Info: Found template $templateFilename. Copy to $CATALINA_HOME/webapps/ROOT/WEB-INF/classes/";
    cp "$templateFilename" "$CATALINA_HOME/webapps/ROOT/WEB-INF/classes/${templateFilename//\/run\/secrets\/}";
  fi
done

if [ "${USE_PROXYCHAIN^^}" = "TRUE" ]; then
  if [ -z "${HTTP_PROXY_URL}" ]; then
    echo "Info: HTTP_PROXY_URL variable is empty. Stopping proxychains configuration."
  else
    PROTO="$(echo $HTTP_PROXY_URL | grep :// | sed -e's,^\(.*://\).*,\1,g')"
    echo $PROTO
    URL="$(echo ${HTTP_PROXY_URL/$PROTO/})"
    echo $URL
    HOST="$(echo $URL | sed -e 's,:.*,,g')"
    echo $HOST
    PORT="$(echo $URL | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"
    echo $PORT
    IP="$(getent hosts $HOST | cut -d ' ' -f 1 | tail -1)"
    echo $IP
    sed -e "s/PROXYIP/$IP/g; s/PROXYPORT/$PORT/g" /etc/proxychains4.conf > /tmp/proxychains4.conf
    if [ "proxychains-is-happy" != "$(/docker/proxify.sh echo proxychains-is-happy)" ]; then
      echo "Error: Failed to configure proxychains with proxy $HTTP_PROXY_URL (= HTTP_PROXY_URL)"
      exit 1
    fi
    echo "Info: Successfully configured proxychains with proxy $HTTP_PROXY_URL (= HTTP_PROXY_URL)"
    # Ensure proxy handling is stopped here
    unset HTTP_PROXY_URL HTTP_PROXY_USERNAME HTTP_PROXY_PASSWORD HTTPS_PROXY_URL HTTPS_PROXY_USERNAME HTTPS_PROXY_PASSWORD NO_PROXY_HOSTS
  fi
fi

### Iterate through templates copied to container
echo "Info: Checking for config template files in $CATALINA_HOME/webapps/ROOT/WEB-INF/classes/"
for templateFilename in $CATALINA_HOME/webapps/ROOT/WEB-INF/classes/*; do
  if [[ $templateFilename == *".docker."* ]]; then
    echo "Info: Found template $templateFilename";
    filename="${templateFilename//.docker/}";
    echo "Info: Using template $templateFilename for file $filename";
    for var in $(compgen -e | grep -i "$COMPONENT"); do
      echo "Info: Updating value of environment variable $var";
      sed -i "s|$var|${!var}|g" "$templateFilename";
    done
    # common variables which are available for usage in every container
    common_vars="HTTP_PROXY_URL HTTP_PROXY_USERNAME HTTP_PROXY_PASSWORD HTTPS_PROXY_URL HTTPS_PROXY_USERNAME HTTPS_PROXY_PASSWORD NO_PROXY_HOSTS"
    for var in $common_vars; do
      echo "Info: Updating value of environment variable $var";
      sed -i "s|$var|${!var}|g" "$templateFilename";
    done
    cp -f "$templateFilename" "${filename}";
  fi
done
