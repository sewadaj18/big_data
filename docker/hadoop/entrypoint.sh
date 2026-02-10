#!/bin/bash

# Démarrage du service SSH
service ssh start

# Configuration du fichier hosts
echo "172.25.0.10 master" >> /etc/hosts
echo "172.25.0.11 worker1" >> /etc/hosts
echo "172.25.0.12 worker2" >> /etc/hosts

# Création des répertoires nécessaires
mkdir -p /opt/hadoop/data/namenode
mkdir -p /opt/hadoop/data/datanode
mkdir -p /opt/hadoop/tmp

if [ "$NODE_TYPE" = "master" ]; then
    echo "=== Démarrage du Master Node ==="
    
    # Formatage du NameNode (seulement si pas déjà formaté)
    if [ ! -d "/opt/hadoop/data/namenode/current" ]; then
        echo "Formatage du NameNode..."
        hdfs namenode -format -force
    fi
    
    # Attente que les workers soient prêts
    sleep 10
    
    # Démarrage HDFS
    echo "Démarrage HDFS..."
    $HADOOP_HOME/sbin/start-dfs.sh
    
    # Démarrage YARN
    echo "Démarrage YARN..."
    $HADOOP_HOME/sbin/start-yarn.sh
    
    # Création du répertoire pour les logs Spark
    sleep 5
    hdfs dfs -mkdir -p /spark-logs
    
    # Démarrage Spark Master
    echo "Démarrage Spark Master..."
    $SPARK_HOME/sbin/start-master.sh
    
    echo "=== Master Node démarré ==="
    echo "HDFS NameNode UI: http://localhost:9870"
    echo "YARN ResourceManager UI: http://localhost:8088"
    echo "Spark Master UI: http://localhost:8080"
    
elif [ "$NODE_TYPE" = "worker" ]; then
    echo "=== Démarrage du Worker Node ==="
    
    # Attente du master
    sleep 15
    
    # Démarrage Spark Worker
    echo "Démarrage Spark Worker..."
    $SPARK_HOME/sbin/start-worker.sh spark://master:7077
    
    echo "=== Worker Node démarré ==="
fi

# Garder le conteneur actif
tail -f /dev/null
