# Stage 1: Build project
FROM alpine:latest as builder
## Installing java manually 
ENV JAVA_HOME /opt/jdk/jdk-17.0.9+9
ENV PATH $JAVA_HOME/bin:$PATH
ADD https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%2B9/OpenJDK17U-jdk_x64_alpine-linux_hotspot_17.0.9_9.tar.gz /opt/jdk/
RUN tar -xzvf /opt/jdk/OpenJDK17U-jdk_x64_alpine-linux_hotspot_17.0.9_9.tar.gz -C /opt/jdk/
RUN ["jlink", "--compress=2", \
     "--module-path", "/opt/jdk/jdk-17.0.9+9/jmods/", \
     "--add-modules", "java.base,java.logging,java.naming,java.management,sun.management,java.instrument,java.security.jgss,java.desktop,jdk.unsupported", \
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
WORKDIR /opt/jdk
COPY --from=builder /springboot-runtime .
ENV PATH=$PATH:/opt/jdk/bin

WORKDIR /opt/app
COPY --from=builder /app/opentelemetry-javaagent.jar .
COPY --from=builder /app/build/libs/devices-api.jar .

ENTRYPOINT ["java", "-javaagent:opentelemetry-javaagent.jar", "-jar","/opt/app/devices-api.jar"]
