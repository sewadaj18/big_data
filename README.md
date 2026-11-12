# Mini data lake : Hadoop et Spark sur Docker

Cluster Big Data distribué sur trois conteneurs Docker : un master et deux workers.
Je l'ai monté pour comprendre concrètement le fonctionnement de HDFS, YARN et Spark,
et pour vérifier qu'un fichier reste accessible quand un nœud tombe.

## Architecture

```
                 master (172.25.0.10)
         NameNode, ResourceManager, Spark Master
                         |
          +--------------+--------------+
          |                             |
  worker1 (172.25.0.11)         worker2 (172.25.0.12)
  DataNode, NodeManager,        DataNode, NodeManager,
  Spark Worker                  Spark Worker
```

| Composant | Version |
|---|---|
| Ubuntu (image de base) | 22.04 |
| Java | OpenJDK 8 |
| Hadoop (HDFS, YARN) | 3.3.6 |
| Spark / PySpark | 3.5.1 |

Les trois nœuds partagent la même image (`docker/hadoop/Dockerfile`). C'est la variable `NODE_TYPE` qui décide
au démarrage des services à lancer (`docker/hadoop/entrypoint.sh`). Le master formate le NameNode au premier
lancement, puis démarre HDFS et YARN sur tout le cluster par SSH, et enfin le Spark Master.
Les workers rejoignent ensuite le Spark Master.

Configuration principale :
- `dfs.replication = 2` : chaque bloc est stocké sur les deux DataNodes ;
- réseau Docker dédié `172.25.0.0/16` avec des IP fixes, et noms résolus via `/etc/hosts`.

## Lancer le cluster

Prérequis : Docker et Docker Compose, environ 4 Go de RAM libres.

```bash
./download_dependencies.sh   # récupère les archives Hadoop et Spark dans docker/hadoop/downloads (une seule fois)
docker-compose build
docker-compose up -d
docker-compose ps
```

L'initialisation prend une trentaine de secondes. Interfaces web :

| Service | URL |
|---|---|
| HDFS NameNode | http://localhost:9870 |
| YARN ResourceManager | http://localhost:8088 |
| Spark Master | http://localhost:8080 |

Pour vérifier que les deux DataNodes et les deux NodeManagers sont bien enregistrés :

```bash
docker exec -it hadoop-master hdfs dfsadmin -report
docker exec -it hadoop-master yarn node -list
```

## Tests réalisés

### 1. Ingestion dans HDFS

Le dossier `data/` est monté dans les conteneurs sous `/data`.

```bash
docker exec -it hadoop-master bash
hdfs dfs -mkdir -p /data
hdfs dfs -put /data/input.txt /data/
hdfs dfs -cat /data/input.txt
```

### 2. WordCount distribué avec PySpark

`scripts/test_wordcount.py` lit `input.txt` depuis HDFS, compte les mots, affiche les 20 plus fréquents
et écrit le résultat dans `hdfs:///data/output`.

```bash
spark-submit --master spark://master:7077 /scripts/test_wordcount.py
hdfs dfs -cat /data/output/part-00000 | head -20
```

### 3. Analyse d'un CSV

`scripts/test_csv_analysis.py` charge un CSV, affiche son schéma et ses statistiques descriptives,
puis l'enregistre au format Parquet. Le dépôt ne fournit pas de CSV : il faut placer un fichier
`dataset.csv` dans `data/` avant de le lancer.

```bash
hdfs dfs -put /data/dataset.csv /data/
spark-submit --master spark://master:7077 /scripts/test_csv_analysis.py
```

### 4. Tolérance aux pannes

```bash
docker exec -it hadoop-master hdfs dfs -put /data/input.txt /data/test_replication.txt
docker exec -it hadoop-master hdfs fsck /data/test_replication.txt -files -blocks -locations

docker stop hadoop-worker1
docker exec -it hadoop-master hdfs dfs -cat /data/test_replication.txt   # toujours lisible
docker start hadoop-worker1
```

Avec un facteur de réplication de 2, chaque bloc a une copie sur chaque DataNode. La perte d'un worker ne
rend donc pas le fichier inaccessible. `fsck` indique ensuite les blocs sous-répliqués jusqu'au retour du nœud.

## Limites

C'est un environnement de labo, pas une configuration à reproduire en production :
- tous les services tournent en `root` ;
- la paire de clés SSH est générée au build de l'image, donc identique sur les trois nœuds ;
- aucune authentification (pas de Kerberos) et des interfaces web exposées sans contrôle d'accès ;
- un seul NameNode : si le master s'arrête, HDFS n'est plus disponible.

## Arrêt

```bash
docker-compose down      # arrête le cluster
docker-compose down -v   # supprime aussi les volumes
```
