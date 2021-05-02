FROM maven:3.6.3-jdk-11-slim AS build  
COPY ExampleApp/src /usr/src/app/src  
COPY ExampleApp/pom.xml /usr/src/app  
RUN mvn -f /usr/src/app/pom.xml clean package

FROM store/oracle/weblogic:12.2.1.4-dev
COPY --from=build /usr/src/app/target/*.war /usr/app/ExampleApp.war
EXPOSE 7001 9002
