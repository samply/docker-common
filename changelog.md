# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## Unreleased
## [0.6.2] - 2022-11-18
### Fixed
- Remote debug mode with jdk version > 9 (See: https://www.oracle.com/java/technologies/javase/9-notes.html#JDK-8041435)
## [0.6.1] - 2022-11-16
## [0.6.0] - 2022-11-16
### Changed
- The base image for tomcat-common is now `tomcat:9-jdk17-temurin-focal`.
## [0.5.3] - 2022-07-21
### Fixed
- Tomcat Entrypoint script will now again add user provided certificates to the java truststore.
## [0.5.2] - 2022-07-11
### Fixed
- Now stopping proxychains configuration with `USE_PROXYCHAINS=true` but `HTTP_PROXY_URL` is empty.
## [0.5.1] - 2022-07-11
### Fixed
- Fixed Check for existence of user provided certificates. Before, since version 0.5.0 even if the user provided a certificate it wouldn't be loaded.
## [0.5.0] - 2022-07-05
### Added
- Added Mount Point for User Provided Certificates in Dockerfile for Tomcat. This will ensure, that the final user running the process in container will have permission to access those certificates.
- Added `USE_PROXYCHAIN` environment variable to the tomcat-common image. This will start the tomcat with [proxychains](https://github.com/haad/proxychains) enabled.
### Changed
- The base image for tomcat-common is now `tomcat:9-jdk8-temurin-focal`. The `tomcat:9-jdk8-temurin` version caused issues on some virtual machines.
### Removed
- Deprecated build.sh that was used in previous versions for building docker-common images. The script is no longer needed, because we simplified the build process by using ONBUILD commands in the Dockerfile.
- Jenkinsfile, because we replaced Jenkins with the Github Actions Workflows. These will automatically create releases and push them to Docker Hub.
## [0.4.3] - 2021-12-14
### Fixed
- Permission Denied Exeception then user supplies own certificate
## [0.4.2] - 2021-09-14
### Changed
- Decreased Tomcat Version from 10 to 9. Some of the depending components won't start with Tomcat 10.
## [0.4.1] - 2021-09-14
### Fixed
- The TOMCAT\_REVERSEPROXY\_PORT environment variable now works as expected. If not set it defaults to port 80 for http and port 443 for https.
- Instead of searching secrets for all defined environment variables, the start up script will now set environment variables from all files added to the container before startup at "/run/secrets" ending with either "\_secret" or "\_SECRET".
## [0.4.0] - 2021-05-14
### Added
- Proxy environment variables, which are available for use in every inheriting image
### Fixed
- Removed RemoteValve Configuration in reverseproxy settings. The settings there resulted in overriding the original reverseproxy settings
- Switched to Dockerfiles USER instruction instead of switching the user at the end of entrypoint. The original way resulted in longer container shutdowns due to multiple processes running in the container
## [0.3.1] - 2021-03-19
### Fixed
- Permission denied exception then starting with activated reverse proxy configuration
## [0.3.0] - 2021-03-19
### Added 
- Possibility to import self signed certificates for the application to trust. You need to create a volume that mounts into "/docker/custom-certs" and place your certificates there.
### Changed
- The scripts are no longer saved in "/scripts" and instead in "/docker/". In the future all files related to the docker container will be saved inside this directory.
### Removed
- Automatic import of the build context to "$CATALINA_HOME/webapps/ROOT". For more flexibility then inheriting from the tomcat-common image we removed this automation. You now need to copy it in your own Dockerfile, e.g with "COPY . $CATALINA_HOME/webapps/ROOT/" 
## [0.2.0] - 2021-01-29
This is just a summary of features for one of the first releases. All future releases including this release will be published on [docker hub](https://hub.docker.com/r/samply/docker-common).
### Added
- Engine for inserting values of environment variables into configuration files. All files placed at "$CATALINA_HOME/webapps/$DEPLOYMENT_CONTEXT/WEB-INF/classes/" matching the pattern "\*.docker.\*" are processed as templates.
- Support for docker secrets. Each environment variable used in a template is also available as a secret to the end user. The naming pattern is following "<COMPONENT>_<ENVIRONMENT_VARIABLE_NAME>_SECRET"
- COMPONENT (default: test) build parameter, this will control different internal settings in the final image. For example the templating engine will only search for variables prefixed with the uppercase value of this variable and an underscore.
- MANDATORY_VARIABLES (default: <none>) build parameter, which enables users of the tomcat common image to define variables which their users must define.
- DEBUG environment variable. This will cause the tomcat to start with an open JPDA port that users can use for remote debugging.
- TOMCAT_REVERSEPROXY_FQDN and TOMCAT_REVERSEPROXY_SSL environment variables for configuring tomcat to use a reverse proxy.
- DEPLOYMENT_CONTEXT environment variable, which allows the user to run their application in a specific subpath in tomcat.

