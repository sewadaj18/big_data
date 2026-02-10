#!/usr/bin/env python3
"""
Script PySpark pour analyser un fichier CSV
Exemple : Calcul de statistiques sur des données météo ou transactions
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import avg, count, max, min

def main():
    # Création de la session Spark
    spark = SparkSession.builder \
        .appName("CSV-Analysis-Academic") \
        .master("spark://master:7077") \
        .getOrCreate()
    
    print("=== Analyse de données CSV ===")
    
    # Lecture du fichier CSV depuis HDFS
    df = spark.read.csv("hdfs://master:9000/data/dataset.csv", 
                        header=True, 
                        inferSchema=True)
    
    # Affichage du schéma
    print("\n=== Schéma des données ===")
    df.printSchema()
    
    # Affichage des premières lignes
    print("\n=== Aperçu des données ===")
    df.show(10)
    
    # Statistiques descriptives
    print("\n=== Statistiques descriptives ===")
    df.describe().show()
    
    # Comptage des lignes
    total_rows = df.count()
    print(f"\nNombre total de lignes: {total_rows}")
    
    # Sauvegarde des résultats
    df.write.mode("overwrite").parquet("hdfs://master:9000/data/output_parquet")
    
    print("\n=== Analyse terminée ===")
    print("Résultats sauvegardés dans: hdfs://master:9000/data/output_parquet")
    
    spark.stop()

if __name__ == "__main__":
    main()
