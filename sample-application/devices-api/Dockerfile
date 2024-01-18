# Stage 1: Build project
FROM alpine:latest as builder
## Installing java manually 
ENV JAVA_HOME /opt/jdk/jdk-21.0.1+12
ENV PATH $JAVA_HOME/bin:$PATH
ADD https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.1%2B12/OpenJDK21U-jdk_x64_alpine-linux_hotspot_21.0.1_12.tar.gz /opt/jdk/
RUN tar -xzvf /opt/jdk/OpenJDK21U-jdk_x64_alpine-linux_hotspot_21.0.1_12.tar.gz -C /opt/jdk/
RUN ["jlink", "--compress=2", \
     "--module-path", "/opt/jdk/jdk-21.0.1+12/jmods/", \
     "--add-modules", "java.base,java.logging,java.naming,java.desktop,jdk.unsupported", \
     "--no-header-files", "--no-man-pages", \
     "--output", "/springboot-runtime"]
RUN mkdir /app
COPY . /app
WORKDIR /app
## Assemble project
RUN ./gradlew build
## Download opentelemetry-javaagent.jar
RUN apk --no-cache add curl
RUN curl -L -O https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.31.0/opentelemetry-javaagent.jar

# Stage 2: Run 
FROM alpine:latest
COPY --from=builder /springboot-runtime /opt/jdk
ENV PATH=$PATH:/opt/jdk/bin
WORKDIR /app
COPY --from=builder /app/opentelemetry-javaagent.jar /app
COPY --from=builder /app/build/libs/devices-api.jar /app

ENTRYPOINT ["java", "-javaagent:opentelemetry-javaagent.jar", "-jar","devices-api.jar"]
