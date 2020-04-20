#!/bin/bash -e
# COMPONENT=$1; # The component for which an container should be build
# COMPONENT_REPOSITORY=$2; # The git clone link of components repository
COMMON_REPOSITORY_COMMIT="1a76e2dd03f1816cf4c7007d991e14d9eb700e8b";
MAVEN_HOME="maven-home";
# if [ -z "$COMPONENT" ] || [ -z "$COMPONENT_REPOSITORY" ]; then
#   echo "The arguments COMPONENT and COMPONENT_REPOSITORY are mandatory. Please specify them.";
#   exit 1;
# fi
while getopts "c:r:h:m:" OPTION
do
  case "${OPTION}"
    in
    c)
      COMPONENT=${OPTARG};;
    r)
      COMPONENT_REPOSITORY=${OPTARG};;
    h)
      COMMON_REPOSITORY_COMMIT=${OPTARG};;
    m)
      MAVEN_HOME=${OPTARG};;
  esac
done
docker build -t $COMPONENT-builder --build-arg COMPONENT=$COMPONENT -f- $COMPONENT_REPOSITORY < Dockerfile.builder;
if [ -d "$(pwd)/artifacts" ]; then
  rm -r artifacts;
fi
docker run -it --rm --name $COMPONENT-build -v /$(pwd)/artifacts://usr/src/$COMPONENT-build/target -v $MAVEN_HOME://root/.m2 $COMPONENT-builder mvn install;
### This should not take context. It should take WAR File produced in step before
docker build -t $COMPONENT:wip --build-arg COMPONENT=$COMPONENT --build-arg COMMIT_HASH=$COMMON_REPOSITORY_COMMIT -f- $(pwd)/artifacts/ < Dockerfile;
exit 0;
