FROM ubuntu:24.10
ENV TOMCAT_VERSION=11.0.2
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN wget -O /tmp/tomcat.tar.gz https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.2/bin/apache-tomcat-11.0.2.tar.gz && \
    tar xf /tmp/tomcat.tar.gz -C /opt && \
    rm /tmp/tomcat.tar.gz && \
    mv /opt/apache-tomcat-11.0.2 /opt/tomcat
ENV CATALINA_HOME=/opt/tomcat
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$CATALINA_HOME/bin:/usr/lib/jvm/java-17-openjdk-amd64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
EXPOSE 8080
RUN rm -rf /var/lib/apt/lists/* 
RUN rm -rf /opt/tomcat/webapps/*
RUN mkdir /opt/tomcat/webapps-javaee
COPY target/petclinic.war /opt/tomcat/webapps-javaee/petclinic.war
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
