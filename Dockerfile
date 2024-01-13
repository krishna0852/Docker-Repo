# Stage 1: Build stage
FROM ubuntu as builder

ARG JAVA_VERSION=17
ARG MAVEN_VERSION=3.9.5

RUN mkdir /softwares
WORKDIR /softwares

RUN apt-get update -y && apt-get install curl -y
RUN curl -O https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xvf apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && rm -rf apache-maven-${MAVEN_VERSION}-bin.tar.gz

# Stage 2: Final stage
FROM ubuntu

ARG JAVA_VERSION=17
ARG MAVEN_VERSION=3.9.5
ARG TOMCAT_VERSION=10.1.18
ARG TOMCAT_SERIES=10

# Copying Maven from the builder stage

COPY --from=builder /softwares /softwares

# installing java

RUN apt-get update -y  && apt install openjdk-${JAVA_VERSION}-jdk -y

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64 \
    MAVEN_HOME=/softwares/apache-maven-${MAVEN_VERSION} \
    PATH=$PATH:$JAVA_HOME/bin:$MAVEN_HOME/bin

WORKDIR /bin


RUN ln -s /softwares/apache-maven-${MAVEN_VERSION}/bin/mvn mvn

# Cleanup unnecessary directories
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create a non-root user
# RUN useradd -m -d /home/user -s /bin/bash App

# USER App

RUN java -version && mvn -version

RUN apt-get update -y && apt-get  install curl -y

RUN curl -O https://dlcdn.apache.org/tomcat/tomcat-${TOMCAT_SERIES}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz\
    && tar -xvf apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && rm -rf apache-tomcat-${TOMCAT_VERSION}.tar.gz

WORKDIR /usr/bin/apache-tomcat-${TOMCAT_VERSION}/bin


#/usr/bin/apache-tomcat-10.1.18/bin
CMD ["/usr/bin/apache-tomcat-10.1.18/bin/catalina.sh","run"]



