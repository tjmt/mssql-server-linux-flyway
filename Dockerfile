FROM microsoft/mssql-server-linux:2017-latest

ARG FLYWAY_VERSION=5.1.4

# Install OpenJDK-8
RUN apt-get update
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y ca-certificates-java
RUN apt-get install -y ant
RUN apt-get install -y curl
RUN apt-get clean
RUN update-ca-certificates -f

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# Install Flyway
RUN mkdir /flyway \
  && cd /flyway \
  && curl -L https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz -o flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && ln -s /flyway/flyway /usr/local/bin/flyway

RUN rm -rf /flyway/sql/*

# COPY ./sql /flyway/sql

ENTRYPOINT sh -c "until (/opt/mssql/bin/sqlservr); do sleep 1; done & until (/opt/mssql-tools/bin/sqlcmd -l 40 -S localhost -U sa -P ${SA_PASSWORD} -d tempdb -q \"If(db_id('${DATABASE}') IS NULL) CREATE DATABASE ${DATABASE}\"); do sleep 1; done; until (flyway info -user='sa' -password='${SA_PASSWORD}' -url='jdbc:sqlserver://localhost:1433;databaseName=${DATABASE}'); do sleep 5; done; if [ -z \"$(ls -A /flyway/sql)\" ]; then echo 0; else flyway migrate -user='sa' -password='${SA_PASSWORD}' -url='jdbc:sqlserver://localhost:1433;databaseName=${DATABASE}'; flyway info -user='sa' -password='${SA_PASSWORD}' -url='jdbc:sqlserver://localhost:1433;databaseName=${DATABASE}'; fi; wait"
