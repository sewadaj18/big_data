FROM ubuntu:22.04

# Éviter les prompts interactifs
ENV DEBIAN_FRONTEND=noninteractive

# Installation des dépendances
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    wget \
    ssh \
    rsync \
    python3 \
    python3-pip \
    vim \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Variables d'environnement Java
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Installation de Hadoop depuis archive locale
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
COPY downloads/hadoop-${HADOOP_VERSION}.tar.gz /tmp/
RUN tar -xzf /tmp/hadoop-${HADOOP_VERSION}.tar.gz -C /opt && \
    mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME} && \
    rm /tmp/hadoop-${HADOOP_VERSION}.tar.gz

# Installation de Spark depuis archive locale
ENV SPARK_VERSION=3.5.1
ENV SPARK_HOME=/opt/spark
COPY downloads/spark-${SPARK_VERSION}-bin-hadoop3.tgz /tmp/
RUN tar -xzf /tmp/spark-${SPARK_VERSION}-bin-hadoop3.tgz -C /opt && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop3 ${SPARK_HOME} && \
    rm /tmp/spark-${SPARK_VERSION}-bin-hadoop3.tgz

# Installation de PySpark
RUN pip3 install --no-cache-dir pyspark==${SPARK_VERSION}

# Configuration des variables d'environnement
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$SPARK_HOME/sbin
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV HDFS_NAMENODE_USER=root
ENV HDFS_DATANODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root
ENV YARN_RESOURCEMANAGER_USER=root
ENV YARN_NODEMANAGER_USER=root

# Configuration SSH
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

# Ajouter JAVA_HOME au hadoop-env.sh
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh

# Copie des fichiers de configuration
COPY config/* ${HADOOP_CONF_DIR}/
COPY spark-config/* ${SPARK_HOME}/conf/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /opt

ENTRYPOINT ["/entrypoint.sh"]
