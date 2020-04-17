#!/bin/bash -e
if [ -z "$1"] || [ -z "$2" ]; then
  echo "Please specify COMPONENT (first parameter) and COMPONENT_REPOSITORY(second parameter)";
  exit 1;
fi
COMPONENT=$1; # The component for which an container should be build
COMPONENT_REPOSITORY=$2; # The git clone link of components repository 
docker build -t $COMPONENT-builder --build-arg COMPONENT=$COMPONENT -f- $COMPONENT_REPOSITORY < Dockerfile.builder;
if [ -d "$(pwd)/artifacts" ]; then
  rm -r artifacts;
fi
docker run -it --rm --name $COMPONENT-build -v /$(pwd)/artifacts://usr/src/$COMPONENT-build/target -v maven-home:/root/.m2 $COMPONENT-builder mvn install;
### This should not take context. It should take WAR File produced in step before
docker build -t $COMPONENT:wip --build-arg COMMIT_HASH=5850e29bcbfb6f375a9151af87d6e06ba2b9a146 -f- $(pwd)/artifacts/ < Dockerfile;
exit 0;
