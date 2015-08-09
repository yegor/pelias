#
# Ubuntu Dockerfile
#
# https://github.com/dockerfile/ubuntu
#

# Pull base image.
#FROM ubuntu:14.04

FROM phusion/baseimage:0.9.17

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Install.
RUN \
  apt-get update && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop unzip vim wget apt-utils && \
  rm -rf /var/lib/apt/lists/*

# Install Java.

# Enable silent install
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

RUN \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer  

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install Elasticsearch.
# ENV ES_PKG_NAME elasticsearch-1.5.0

# # Install Elasticsearch.
# RUN \
#   cd / && \
#   wget https://download.elasticsearch.org/elasticsearch/elasticsearch/$ES_PKG_NAME.tar.gz && \
#   tar xvzf $ES_PKG_NAME.tar.gz && \
#   rm -f $ES_PKG_NAME.tar.gz && \
#   mv /$ES_PKG_NAME /elasticsearch

# RUN wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.4.deb
# RUN sudo dpkg -i elasticsearch-1.4.4.deb
# RUN sudo update-rc.d elasticsearch defaults 95 10

# Install Python.
RUN \
  apt-get update && \
  apt-get install -y python python-dev python-pip python-virtualenv && \
  rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN \
  cd /tmp && \
  wget http://nodejs.org/dist/node-latest.tar.gz && \
  tar xvzf node-latest.tar.gz && \
  rm -f node-latest.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  npm install -g npm && \
  printf '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

# Install Elasticsearch.
ENV ES_PKG_NAME elasticsearch-1.5.0
RUN \
  cd / && \
  wget https://download.elasticsearch.org/elasticsearch/elasticsearch/$ES_PKG_NAME.tar.gz && \
  tar xvzf $ES_PKG_NAME.tar.gz && \
  rm -f $ES_PKG_NAME.tar.gz && \
  mv /$ES_PKG_NAME /elasticsearch

# Adding groovy scripts
ADD scripts /elasticsearch/config/scripts

# Auxiliary folders
RUN rm -rf /mnt
RUN mkdir -p /mnt/data/openstreetmap
RUN mkdir -p /tmp/openstreetmap/
RUN mkdir -p /mnt/data/quattroshapes
RUN mkdir -p /mnt/data/geonames
RUN mkdir -p /var/log/esclient/

# Downloading dev content
WORKDIR /mnt/data/quattroshapes
RUN curl -O http://quattroshapes.mapzen.com/quattroshapes/quattroshapes-simplified.tar.gz
RUN tar zxvf quattroshapes-simplified.tar.gz && rm -f quattroshapes-simplified.tar.gz
RUN cp simplified/* . && rm -rf quattroshapes-simplified/

WORKDIR /mnt/data/openstreetmap
RUN curl -O http://download.geofabrik.de/europe/russia-european-part-latest.osm.pbf
RUN curl -O http://download.geofabrik.de/europe/belarus-latest.osm.pbf

# setting workind
WORKDIR /root

#
# Pelias
#

#  Copying pelias config ile
ADD pelias.json pelias.json

#  Install Pelias CLI
RUN npm install -g pelias-cli

RUN mkdir -p /etc/service/elasticsearch
ADD elasticsearch.sh /etc/service/elasticsearch/run

RUN mkdir -p /etc/service/pelias-api
ADD api.sh /etc/service/pelias-api/run

RUN /elasticsearch/bin/elasticsearch -d && pelias schema create_index && pelias geonames import -i BY && pelias geonames import -i RU && pelias openstreetmap import
RUN pelias api test

CMD bash
#CMD service elasticsearch start && pelias api start
#CMD ["/sbin/my_init"]