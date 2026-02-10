#!/usr/bin/env python3
"""
Script PySpark pour compter les occurrences de mots
Cas pratique académique : Traitement distribué sur le cluster
"""

from pyspark.sql import SparkSession

def main():
    # Création de la session Spark
    spark = SparkSession.builder \
        .appName("WordCount-Academic") \
        .master("spark://master:7077") \
        .getOrCreate()
    
    print("=== Démarrage du traitement distribué ===")
    
    # Lecture du fichier depuis HDFS
    text_file = spark.sparkContext.textFile("hdfs://master:9000/data/input.txt")
    
    # Traitement : comptage des mots
    counts = text_file.flatMap(lambda line: line.split(" ")) \
                      .map(lambda word: (word.lower(), 1)) \
                      .reduceByKey(lambda a, b: a + b)
    
    # Tri par fréquence décroissante
    sorted_counts = counts.sortBy(lambda x: x[1], ascending=False)
    
    # Affichage des 20 mots les plus fréquents
    print("\n=== Top 20 des mots les plus fréquents ===")
    for word, count in sorted_counts.take(20):
        print(f"{word}: {count}")
    
    # Sauvegarde des résultats dans HDFS
    sorted_counts.saveAsTextFile("hdfs://master:9000/data/output")
    
    print("\n=== Traitement terminé ===")
    print("Résultats sauvegardés dans: hdfs://master:9000/data/output")
    
    spark.stop()

if __name__ == "__main__":
    main()
