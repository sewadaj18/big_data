# Mini-Data Lake Académique

Projet pédagogique de mise en place d'un cluster Big Data distribué avec Hadoop, HDFS, YARN et Spark.

## 🎯 Objectifs Pédagogiques

1. **Comprendre l'architecture distribuée** : Master/Worker avec 3 nœuds
2. **Maîtriser HDFS** : Stockage distribué avec réplication
3. **Gérer les ressources** : YARN pour l'ordonnancement
4. **Traiter les données** : Spark pour le calcul en mémoire
5. **Tester la tolérance aux pannes** : Simulation de défaillance

## 🏗️ Architecture du Cluster

```
┌─────────────────────────────────────────────────┐
│              MASTER NODE (172.25.0.10)          │
│  - NameNode (HDFS)                              │
│  - ResourceManager (YARN)                       │
│  - Spark Master                                 │
└─────────────────────────────────────────────────┘
                      │
        ┌─────────────┴─────────────┐
        │                           │
┌───────▼──────────┐      ┌────────▼─────────┐
│  WORKER 1        │      │  WORKER 2        │
│  (172.25.0.11)   │      │  (172.25.0.12)   │
│  - DataNode      │      │  - DataNode      │
│  - NodeManager   │      │  - NodeManager   │
│  - Spark Worker  │      │  - Spark Worker  │
└──────────────────┘      └──────────────────┘
```

## 📦 Composants Installés

| Composant | Version | Rôle |
|-----------|---------|------|
| **Hadoop** | 3.3.6 | Stockage distribué (HDFS) + Gestion ressources (YARN) |
| **Spark** | 3.5.0 | Moteur de calcul en mémoire |
| **Java** | OpenJDK 8 | Runtime pour Hadoop/Spark |
| **Python** | 3.10 | Scripts PySpark |

## 🚀 Démarrage du Cluster

### 1. Télécharger les dépendances (une seule fois)

```bash
# Télécharger Hadoop (696 MB) et Spark (400 MB)
./download_dependencies.sh
```

**Note** : Le téléchargement peut prendre 10-30 minutes selon votre connexion. Le script reprend automatiquement en cas d'interruption.

### 2. Construire les images Docker

```bash
docker-compose build
```

### 3. Lancer l'infrastructure

```bash
docker-compose up -d
```

### 4. Vérifier l'état des conteneurs

```bash
docker-compose ps
```

### 3. Accéder aux interfaces Web

- **HDFS NameNode** : http://localhost:9870
- **YARN ResourceManager** : http://localhost:8088
- **Spark Master** : http://localhost:8080

## 📊 Cas Pratiques

### Test 1 : Ingestion de données dans HDFS

```bash
# Accéder au master
docker exec -it hadoop-master bash

# Créer un répertoire dans HDFS
hdfs dfs -mkdir -p /data

# Charger un fichier
hdfs dfs -put /data/input.txt /data/

# Vérifier le fichier
hdfs dfs -ls /data/
hdfs dfs -cat /data/input.txt
```

### Test 2 : Traitement distribué avec PySpark (WordCount)

```bash
# Dans le conteneur master
docker exec -it hadoop-master bash

# Lancer le script de comptage de mots
spark-submit --master spark://master:7077 /scripts/test_wordcount.py

# Voir les résultats
hdfs dfs -cat /data/output/part-00000 | head -20
```

### Test 3 : Analyse CSV avec Spark

```bash
# Charger un fichier CSV dans HDFS
hdfs dfs -put /data/dataset.csv /data/

# Lancer l'analyse
spark-submit --master spark://master:7077 /scripts/test_csv_analysis.py
```

## 🔥 Test de Tolérance aux Pannes

### Démonstration du facteur de réplication

```bash
# 1. Charger un fichier important
docker exec -it hadoop-master bash
hdfs dfs -put /data/input.txt /data/test_replication.txt

# 2. Vérifier la réplication (doit être sur 2 DataNodes)
hdfs fsck /data/test_replication.txt -files -blocks -locations

# 3. Arrêter un Worker
docker stop hadoop-worker1

# 4. Vérifier que le fichier est toujours accessible
hdfs dfs -cat /data/test_replication.txt

# 5. Redémarrer le Worker
docker start hadoop-worker1
```

**Résultat attendu** : Le fichier reste accessible même avec un Worker arrêté grâce au facteur de réplication = 2.

## 📈 Monitoring du Cluster

### Vérifier l'état HDFS

```bash
docker exec -it hadoop-master hdfs dfsadmin -report
```

### Vérifier les nœuds YARN

```bash
docker exec -it hadoop-master yarn node -list
```

### Logs des services

```bash
# Logs du master
docker logs hadoop-master

# Logs d'un worker
docker logs hadoop-worker1
```

## 🛠️ Commandes Utiles

### HDFS

```bash
# Lister les fichiers
hdfs dfs -ls /

# Créer un répertoire
hdfs dfs -mkdir /mon_dossier

# Copier depuis local vers HDFS
hdfs dfs -put fichier.txt /data/

# Copier depuis HDFS vers local
hdfs dfs -get /data/fichier.txt .

# Supprimer un fichier
hdfs dfs -rm /data/fichier.txt

# Voir l'espace disque
hdfs dfs -df -h
```

### Spark

```bash
# Soumettre un job Spark
spark-submit --master spark://master:7077 script.py

# Shell interactif PySpark
pyspark --master spark://master:7077
```

## 📝 Points Clés pour le Rapport Académique

### 1. Installation et Configuration
- Configuration du fichier `/etc/hosts` pour la résolution DNS
- Échange de clés SSH entre les nœuds
- Paramétrage du facteur de réplication (dfs.replication=2)

### 2. Architecture Distribuée
- Séparation Master/Worker
- Répartition des rôles (NameNode, DataNode, ResourceManager, NodeManager)
- Communication inter-nœuds via réseau Docker

### 3. Tolérance aux Pannes
- Réplication des blocs de données
- Test de défaillance d'un Worker
- Récupération automatique

### 4. Performance
- Calcul distribué avec Spark
- Comparaison temps de traitement local vs distribué
- Utilisation de la mémoire (Spark) vs disque (MapReduce)

## 🧹 Nettoyage

```bash
# Arrêter le cluster
docker-compose down

# Supprimer les volumes (données persistantes)
docker-compose down -v

# Supprimer les images
docker rmi $(docker images -q mini-data-lake*)
```

## 📚 Ressources

- [Documentation Hadoop](https://hadoop.apache.org/docs/stable/)
- [Documentation Spark](https://spark.apache.org/docs/latest/)
- [HDFS Architecture](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HdfsDesign.html)
- [YARN Architecture](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/YARN.html)

## 🎓 Auteur

Projet académique - Mini-Data Lake pour démonstration pédagogique
