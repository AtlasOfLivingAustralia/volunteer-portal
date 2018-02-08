#!/bin/sh
./gradlew assemble

GRAILS_OPTS="-Dendpoints.shutdown.enabled=true -Dfull.stacktrace=false -Dgrails.full.stacktrace=false -Dinfo.app.name=volunteer-portal -Djdk.reflect.allowGetCallerClass=true -Drun.active=true -Dspring.output.ansi.enabled=always -Dfile.encoding=UTF-8 -Duser.country=AU -Duser.language=en -Duser.variant"
java ${GRAILS_OPTS} -Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=8000,suspend=n -Xmx2g -jar build/libs/volunteer-portal-4.0-SNAPSHOT.war
