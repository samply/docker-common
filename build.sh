#!/bin/bash -e
COMMON_REPOSITORY="https://bitbucket.org/brennert/docker.common";
COMMON_REPOSITORY_COMMIT="1a76e2dd03f1816cf4c7007d991e14d9eb700e8b";
MAVEN_HOME="maven-home";
BUILDER="none";
while getopts "c:r:h:m:b:" OPTION
do
  case "${OPTION}"
    in
    c)
      COMPONENT=${OPTARG};
      echo "Info: Building component $COMPONENT";;
    r)
      COMPONENT_REPOSITORY=${OPTARG};
      echo "Info: Using component-repository $COMPONENT_REPOSITORY";;
    h)
      COMMON_REPOSITORY_COMMIT=${OPTARG};
      echo "Using COMMON_REPOSITORY_COMMIT $COMMON_REPOSITORY_COMMIT";;
    m)
      MAVEN_HOME=${OPTARG};
      echo "Info: Using ${OPTARG} as MAVEN_HOME";;
    b)
      BUILDER=${OPTARG};
      echo "Info: Using builder $BUILDER";;
  esac
done
if [ -z "$COMPONENT" ] || [ -z "$COMPONENT_REPOSITORY" ]; then
  echo "The arguments COMPONENT and COMPONENT_REPOSITORY are mandatory. Please specify them.";
  exit 1;
fi
### Build artifacts of component for final docker image
if [ $BUILDER != "none" ]; then
  $(curl $COMMON_REPOSITORY/raw/$COMMON_REPOSITORY_COMMIT/$BUILDER/Dockerfile) | docker build -t $COMPONENT-builder --build-arg COMPONENT=$COMPONENT -f - $COMPONENT_REPOSITORY
  if [ -d "$(pwd)/artifacts" ]; then
    rm -r artifacts;
  fi
  docker run -it --rm --name $COMPONENT-build -v /$(pwd)/artifacts://usr/src/$COMPONENT-build/target -v $MAVEN_HOME://root/.m2 $COMPONENT-builder mvn install;
fi
### Build components docker image
if [ ! -d "$(pwd)/artifacts" ]; then
  echo "Error: Can't build component docker image without any artifact to build. Please specify builder or location";
  echo "Note: currently no other location than $(pwd)/artifacts/ is supported";
  exit 1;
fi
curl $COMMON_REPOSITORY/raw/$COMMON_REPOSITORY_COMMIT/tomcat/Dockerfile | docker build -t $COMPONENT:wip --build-arg COMPONENT=$COMPONENT --build-arg COMMIT_HASH=$COMMON_REPOSITORY_COMMIT -f - $(pwd)/artifacts/
exit 0;
