# Build with: docker build --platform linux/amd64 -t qoder2api .
ARG BUILDPLATFORM=linux/amd64

FROM --platform=${BUILDPLATFORM} maven:3.9.9-eclipse-temurin-17-alpine AS build

WORKDIR /workspace

COPY pom.xml ./
RUN mvn -q -DskipTests dependency:go-offline

COPY src ./src
COPY baseprompt.json ./baseprompt.json

RUN mvn -q -DskipTests package

FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

ENV QODER_HOST=0.0.0.0 \
    QODER_PORT=8963

COPY --from=build /workspace/target/qoder-client-*.jar /app/app.jar
COPY --from=build /workspace/baseprompt.json /app/baseprompt.json

EXPOSE 8963

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
