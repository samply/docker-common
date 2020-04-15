#!/bin/bash -e
echo "Info: executing common_entrypoint.sh";
### TODO: How can users of docker common specify default values?
### Process docker secrets
for var in $(compgen -e | grep "$COMPONENT"); do
  echo "Info: Checking secret ${!var}_FILE for environment variable $var"
  if [ -e "/run/secrets/${!var}_FILE" ]; then \
    echo "Info: secret found for ${!var}_FILE. Now writing value back to $var";
    var=$(cat "/run/secrets/${!var}_FILE");
  fi
done

MISSING_VARS=""

## Check for missing variables
echo "Info: Checking if all mandatory variables are specified"
for VAR in $MANDATORY_VARS; do
  if [ -z "${!VAR}" ]; then
    MISSING_VARS+="$VAR "
  fi
done

if [ -n "$MISSING_VARS" ]; then
  echo "Error: Mandatory variables not defined (see documentation): $MISSING_VARS";
  exit 1;
fi

### Iterate through templates copied to container
for templateFilename in /tmp/*.docker.*; do
  echo "Info: Found template $templateFilename";
  filename="${templateFilename//.docker/}";
  echo "Info: Using template $templateFilename for file $filename";
  for var in $(compgen -e | grep "$COMPONENT"); do
    echo "Info: Updating value of environment variable $var";
    sed -i "s|$var|${!var}|g" "$templateFilename";
  done
  echo "$(whoami)"
  echo "$(ls -l $CATALINA_HOME/webapps/$DEPLOYMENT_CONTEXT/WEB-INF/classes/)"
  cp -f "$templateFilename" "$CATALINA_HOME/webapps/$DEPLOYMENT_CONTEXT/WEB-INF/classes/${filename//\/tmp\//}";
done
