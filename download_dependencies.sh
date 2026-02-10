#!/bin/bash

# Script pour télécharger les dépendances Hadoop et Spark
# À exécuter avant docker-compose build

set -e

DOWNLOAD_DIR="./docker/hadoop/downloads"
mkdir -p "$DOWNLOAD_DIR"

echo "=== Téléchargement des dépendances Big Data ==="

# Hadoop 3.3.6
HADOOP_FILE="hadoop-3.3.6.tar.gz"
if [ ! -f "$DOWNLOAD_DIR/$HADOOP_FILE" ]; then
    echo "Téléchargement de Hadoop 3.3.6 (696 MB)..."
    wget -c -O "$DOWNLOAD_DIR/$HADOOP_FILE" \
        https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz || \
    wget -c -O "$DOWNLOAD_DIR/$HADOOP_FILE" \
        https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
    echo "✓ Hadoop téléchargé"
else
    echo "✓ Hadoop déjà téléchargé"
fi

# Spark 3.5.1
SPARK_FILE="spark-3.5.1-bin-hadoop3.tgz"
if [ ! -f "$DOWNLOAD_DIR/$SPARK_FILE" ]; then
    echo "Téléchargement de Spark 3.5.1 (400 MB)..."
    wget -c -O "$DOWNLOAD_DIR/$SPARK_FILE" \
        https://archive.apache.org/dist/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz || \
    wget -c -O "$DOWNLOAD_DIR/$SPARK_FILE" \
        https://dlcdn.apache.org/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz
    echo "✓ Spark téléchargé"
else
    echo "✓ Spark déjà téléchargé"
fi

echo ""
echo "=== Téléchargements terminés ==="
echo "Vous pouvez maintenant lancer: docker-compose build"
