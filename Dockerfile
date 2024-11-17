FROM docker.io/maven:3.9-eclipse-temurin-21-alpine AS dependencies
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Etapa de construcción
FROM docker.io/maven:3.9-eclipse-temurin-21-alpine AS build
WORKDIR /app
COPY --from=dependencies /root/.m2 /root/.m2
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM ghcr.io/la-masa-critica/jre-spring:main AS final
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8761

LABEL maintainer="jorge1b3@hotmail.es" \
      version="2.0" 

LABEL org.opencontainers.image.source = "https://github.com/La-masa-critica/jre-spring"
LABEL org.opencontainers.image.description = "Custom JRE for Spring Boot microservices" 
LABEL org.opencontainers.image.licenses = "MIT"

ENTRYPOINT ["java","-jar","app.jar"]
