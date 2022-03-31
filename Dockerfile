FROM ubuntu:20.04
LABEL maintainer="antares.oier@gmail.com"
USER root
WORKDIR /hadoop

# Load files
COPY data /tmp/data

# Install packages
RUN cp /tmp/data/sources.list /etc/apt/sources.list && \
    apt update && \
    apt install -y --fix-missing openssh-server

# Set environment variables
ENV JAVA_HOME=/opt/jdk
ENV HADOOP_HOME=/opt/hadoop 
ENV PATH=${PATH}:${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin

# Install jdk and hadoop
RUN mv /tmp/data/OpenJDK11U-jdk_x64_linux_hotspot_11.0.14.1_1.tar.gz jdk.tar.gz && \
    mv /tmp/data/hadoop-3.3.2.tar.gz hadoop.tar.gz && \
    tar -zxvf jdk.tar.gz && \
    tar -zxvf hadoop.tar.gz && \
    mv jdk-11.0.14.1+1 ${JAVA_HOME} && \
    mv hadoop-3.3.2 ${HADOOP_HOME} && \
    rm jdk.tar.gz hadoop.tar.gz && \
    cp /tmp/data/env.sh /etc/profile.d/env.sh

# Generate SSH RSA key pair
RUN ssh-keygen -t rsa -f /root/.ssh/id_rsa -P '' && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && \
    cp /tmp/data/ssh_config /root/.ssh/config

# Create hdfs data directory
RUN mkdir -p hdfs/namenode && \ 
    mkdir -p hdfs/datanode && \
    mkdir -p ${HADOOP_HOME}/logs

RUN cp /tmp/data/hadoop_config/core-site.xml ${HADOOP_HOME}/etc/hadoop/core-site.xml && \
    cp /tmp/data/hadoop_config/hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml && \
    cp /tmp/data/hadoop_config/mapred-site.xml ${HADOOP_HOME}/etc/hadoop/mapred-site.xml && \
    cp /tmp/data/hadoop_config/yarn-site.xml ${HADOOP_HOME}/etc/hadoop/yarn-site.xml && \
    cp /tmp/data/hadoop_config/hadoop-env.sh ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh && \
    cp /tmp/data/hadoop_config/workers ${HADOOP_HOME}/etc/hadoop/workers

RUN ${HADOOP_HOME}/bin/hdfs namenode -format

RUN cp /tmp/data/startup.sh startup.sh && \
    chmod +x startup.sh

ENV NAMENODE_WORKER=''
ENV RESOURCES_MANAGER_WORKER=''

# Start
ENTRYPOINT ["/bin/sh","startup.sh"]