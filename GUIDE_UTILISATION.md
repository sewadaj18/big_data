# Guide d'Utilisation - Mini-Data Lake Académique

## 🚀 Démarrage Rapide

### 1. Télécharger les dépendances

```bash
# Télécharger Hadoop et Spark (une seule fois)
./download_dependencies.sh
```

### 2. Construction et lancement du cluster

```bash
# Construire les images
docker-compose build

# Démarrer le cluster (3 nœuds)
docker-compose up -d

# Vérifier que tous les conteneurs sont actifs
docker-compose ps
```

### 3. Attendre l'initialisation (environ 30 secondes)

Le master doit formater le NameNode et démarrer tous les services.

### 4. Vérifier l'état du cluster

```bash
# Accéder au master
docker exec -it hadoop-master bash

# Vérifier HDFS
hdfs dfsadmin -report

# Vérifier YARN
yarn node -list
```

## 📊 Exercices Pratiques

### Exercice 1 : Ingestion de données

```bash
docker exec -it hadoop-master bash

# Créer la structure de répertoires
hdfs dfs -mkdir -p /data

# Charger le fichier de test
hdfs dfs -put /data/input.txt /data/

# Vérifier
hdfs dfs -ls /data/
hdfs dfs -cat /data/input.txt
```

### Exercice 2 : WordCount avec Spark

```bash
docker exec -it hadoop-master bash

# Lancer le traitement distribué
spark-submit --master spark://master:7077 /scripts/test_wordcount.py

# Consulter les résultats
hdfs dfs -ls /data/output/
hdfs dfs -cat /data/output/part-00000 | head -20
```

### Exercice 3 : Test de tolérance aux pannes

```bash
# 1. Charger un fichier
docker exec -it hadoop-master hdfs dfs -put /data/input.txt /data/test_fault.txt

# 2. Vérifier la réplication
docker exec -it hadoop-master hdfs fsck /data/test_fault.txt -files -blocks -locations

# 3. Arrêter un worker
docker stop hadoop-worker1

# 4. Le fichier reste accessible !
docker exec -it hadoop-master hdfs dfs -cat /data/test_fault.txt

# 5. Redémarrer
docker start hadoop-worker1
```

## 🌐 Interfaces Web

- HDFS : http://localhost:9870
- YARN : http://localhost:8088
- Spark : http://localhost:8080

## 🛑 Arrêt du cluster

```bash
docker-compose down
```
