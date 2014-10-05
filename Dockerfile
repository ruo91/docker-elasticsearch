#
# Dockerfile - Elasticsearch
#
# - Build
# git clone https://github.com/ruo91/dockerfile /opt/dockerfile
# docker build --rm -t elasticsearch:source /opt/dockerfile/elasticsearch
#
# - Run
# docker run -d  --name="elasticsearch" -h "elasticsearch" -p 9200:9200 -p 9300:9300 elasticsearch:source
#

# 1. Base images
FROM     ubuntu:14.04
MAINTAINER Yongbok Kim <ruo91@yongbok.net>

# 2. Change the repository
RUN sed -i 's/archive.ubuntu.com/kr.archive.ubuntu.com/g' /etc/apt/sources.list

# 3. The package to update and install
RUN apt-get update && apt-get install -y curl git-core make build-essential 

# 4. Set the environment variable
WORKDIR /opt
ENV SRC_DIR /opt

# 5. Set the Oracle JDK
#ENV JDK_URL http://download.oracle.com/otn-pub/java/jdk
ENV JDK_URL http://cdn.yongbok.net/ruo91/jdk
ENV JDK_VER_1 8u20-b26
ENV JDK_VER_2 8u20
ENV JAVA_HOME /usr/local/jdk
ENV PATH $PATH:$JAVA_HOME/bin
RUN curl -L -o jdk.tar.gz "$JDK_URL/$JDK_VER_1/jdk-$JDK_VER_2-linux-x64.tar.gz" -H 'Cookie: oraclelicense=accept-securebackup-cookie' \
 && tar xzf jdk.tar.gz && mv jdk1* /usr/local/jdk && rm -f jdk.tar.gz

# 6. Set the environment variable for Oracle JDK
RUN echo '# JDK' >> /etc/profile \
 && echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile \
 && echo 'export PATH=\$PATH:\$JAVA_HOME/bin' >> /etc/profile \
 && echo '' >> /etc/profile \

# 7. Set the Apache Maven
ENV MVN_URL http://www.us.apache.org/dist/maven/maven-3
ENV MVN_VER 3.2.2
ENV M2_HOME $SRC_DIR/apache-maven-$MVN_VER
ENV M2 $M2_HOME/bin
ENV PATH $PATH:$M2
RUN curl -LO "$MVN_URL/$MVN_VER/binaries/apache-maven-$MVN_VER-bin.tar.gz" \
 && tar xzf apache-maven*.tar.gz && rm -f apache-maven*.tar.gz

# 8. Set the environment variable for Apache Maven
RUN echo '# Maven' >> /etc/profile \
 && echo "M2_HOME=$SRC_DIR/apache-maven-$MVN_VER" >> /etc/profile \
 && echo 'export M2=\$M2_HOME/bin' >> /etc/profile \
 && echo 'export PATH=\$PATH:\$M2' >> /etc/profile \
 && echo '' >> /etc/profile

# 9. The source build for elasticsearch
ENV ES_URL https://github.com/elasticsearch/elasticsearch
ENV ES_VER 1.x
ENV ES_HOME $SRC_DIR/elasticsearch
ENV PATH $PATH:$ES_HOME/bin
RUN git clone $ES_URL elasticsearch-source && cd elasticsearch-source \
 && git checkout -b $ES_VER origin/$ES_VER && mvn clean package -DskipTests
RUN mv elasticsearch-source/target/releases/*.tar.gz $SRC_DIR \
 && tar xzf elasticsearch*.tar.gz && rm -rf elasticsearch*.tar.gz elasticsearch-source apache-maven* && mv elasticsearch*  elasticsearch

# 10. The install of monitoring plugin for elasticsearch
RUN plugin -install lukas-vlcek/bigdesk
RUN plugin -install mobz/elasticsearch-head
RUN plugin -install lmenezes/elasticsearch-kopf

# 11. Add in the elasticsearch config directory
ADD conf/elasticsearch.yml		$ES_HOME/conf/elasticsearch.yml

# 12. Set the environment variable for elasticsearch
RUN echo '' >> /etc/profile \
 && echo '# Elasticsearch' >> /etc/profile \
 && echo "export ES_HOME=$ES_HOME" >> /etc/profile \
 && echo 'export PATH=\$PATH:\$ES_HOME/bin' >> /etc/profile \
 && echo '' >> /etc/profile

# 13. Port
EXPOSE 9200 9300

# 14. Start elasticsearch
CMD ["elasticsearch"]
