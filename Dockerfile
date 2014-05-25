#
# Dockerfile - Elasticsearch
#
FROM     ubuntu:14.04
MAINTAINER Yongbok Kim <ruo91@yongbok.net>

# Last Package Update & Install
RUN apt-get update && apt-get install -y curl git

# ENV
ENV SRC_DIR /opt

# JDK
ENV JAVA_HOME /usr/local/jdk
ENV PATH $PATH:$JAVA_HOME/bin
RUN curl -LO "http://download.oracle.com/otn-pub/java/jdk/7u55-b13/jdk-7u55-linux-x64.tar.gz" -H 'Cookie: oraclelicense=accept-securebackup-cookie' \
 && tar xzf jdk-7u55-linux-x64.tar.gz && mv jdk1.7.0_55 /usr/local/jdk && rm -f jdk-7u55-linux-x64.tar.gz
RUN echo '# JDK' >> /etc/profile
RUN echo 'export JAVA_HOME="/usr/local/jdk"' >> /etc/profile
RUN echo 'export PATH="$PATH:$JAVA_HOME/bin"' >> /etc/profile
RUN echo '' >> /etc/profile

# Maven
ENV MVN_VER 3.2.1
ENV M2_HOME $SRC_DIR/apache-maven-$MVN_VER
ENV M2 $M2_HOME/bin
ENV PATH $PATH:$M2
RUN cd $SRC_DIR && curl -LO "http://www.us.apache.org/dist/maven/maven-3/$MVN_VER/binaries/apache-maven-$MVN_VER-bin.tar.gz" \
 && tar xzf apache-maven-$MVN_VER-bin.tar.gz

# Elasticsearch
RUN cd $SRC_DIR && git clone https://github.com/elasticsearch/elasticsearch elasticsearch-source \
 && cd elasticsearch-source && git checkout -b 1.x origin/1.x && mvn clean package -DskipTests \
 && mv target/releases/elasticsearch*.tar.gz $SRC_DIR && cd $SRC_DIR && rm -rf elasticsearch-source \
 && tar xzf elasticsearch*.tar.gz && rm -f elasticsearch*.tar.gz && mv elasticsearch*  elasticsearch \
 && $SRC_DIR/elasticsearch/bin/plugin -install mobz/elasticsearch-head \
 && $SRC_DIR/elasticsearch/bin/plugin -install lukas-vlcek/bigdesk && $SRC_DIR/elasticsearch/bin/plugin -install lmenezes/elasticsearch-kopf \
 && rm -rf $SRC_DIR/apache*
ADD conf/elasticsearch.yml $SRC_DIR/elasticsearch/config/elasticsearch.yml

# Daemon
CMD ["/opt/elasticsearch/bin/elasticsearch"]

# Port
EXPOSE 9200 9300
