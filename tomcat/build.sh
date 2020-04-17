#!/bin/bash -e
# if [ -Z "$1" || -Z "$2" ]; then
#   echo "Please specify COMPONENT (first parameter) and CONTEXT(second parameter)"
# fi
COMPONENT=$1; # The component for which an container should be build
CONTEXT=$2; # The git clone link of components repository 
# if [ -d "$(pwd)/artifacts" ]; then
#   mkdir "$(pwd)/artifacts";
# fi
docker build -t $COMPONENT-builder --build-arg COMPONENT=$COMPONENT -f- $CONTEXT < Dockerfile.builder;
if [ -d "$(pwd)/artifacts" ]; then
  rm -r artifacts;
fi
docker run -it --rm --name $COMPONENT-build -v /$(pwd)/artifacts://usr/src/$COMPONENT-build/target -v maven-home:/root/.m2 $COMPONENT-builder mvn install;
### This should not take context. It should take WAR File produced in step before
docker build -t $COMPONENT:wip -f- $(pwd)/artifacts/ < Dockerfile;
