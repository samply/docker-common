#!/bin/bash -e
echo "Info: executing common_entrypoint.sh";
### TODO: How can users of docker common specify default values?
### Process docker secrets
for var in $(compgen -e | grep -i "$COMPONENT"); do
  echo "Info: Checking secret ${var}_FILE for environment variable $var"
  if [ -e "/run/secrets/${var}_FILE" ]; then \
    echo "Info: secret found for ${var}_FILE. Now writing value back to $var";
    var=$(cat "/run/secrets/${var}_FILE");
  fi
done

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
    cp -f "$templateFilename" "${filename}";
  fi
done
