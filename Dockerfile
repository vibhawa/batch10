FROM openjdk:8-jre-alpine
COPY target/*.jar app.jar
ENTRYPOINT ["/usr/bin/java", "-jar", "/app.jar"]
