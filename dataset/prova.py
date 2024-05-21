import json
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, collect_list

# Inizializza la sessione Spark
spark = SparkSession.builder \
    .appName("TEDx-Load-Aggregate-Model") \
    .getOrCreate()

# Imposta i percorsi dei file di input
tedx_dataset_path = "final_list.csv"
details_dataset_path = "details.csv"
images_dataset_path = "images.csv"
related_videos_path = "related_videos.csv"
tags_dataset_path = "tags.csv"

# Carica i dati dai file CSV
tedx_dataset = spark.read.option("header", "true").csv(tedx_dataset_path)
details_dataset = spark.read.option("header", "true").csv(details_dataset_path)
images_dataset = spark.read.option("header", "true").csv(images_dataset_path)
related_video_dataset = spark.read.option("header", "true").csv(related_videos_path)
tags_dataset = spark.read.option("header", "true").csv(tags_dataset_path)

# Esegui le operazioni di trasformazione e join come nel codice originale

# Unisci DataFrame e aggiungi le colonne necessarie
tedx_dataset_main = tedx_dataset.join(details_dataset, tedx_dataset["id"] == details_dataset["id"], "left") \
    .drop("id")

images_dataset = images_dataset.select(col("id").alias("id_ref"), col("url").alias("image_url"))
tedx_dataset_main = tedx_dataset_main.join(images_dataset, tedx_dataset_main["id"] == images_dataset["id"], "left") \
    .drop("id")

related_video_dataset = related_video_dataset.groupBy(col("id").alias("id_from")).agg(collect_list("related_id") \
    .alias("id_related"), collect_list("title").alias("title_related")) 

tedx_dataset_main = tedx_dataset_main.join(related_video_dataset, tedx_dataset_main["id"] == related_video_dataset["id_from"], "left") \
    .drop("id_from") \
    .select(col("id").alias("id_related"), col("*"))

# Stampare lo schema e i primi 5 record del DataFrame dopo ogni operazione
print("Schema del DataFrame dopo join e trasformazioni:")
tedx_dataset_main.printSchema()

print("Primi 5 record del DataFrame dopo join e trasformazioni:")
tedx_dataset_main.show(5)

# Aggrega i dati dei tag
tags_dataset_agg = tags_dataset.groupBy(col("id").alias("id_ref")).agg(collect_list("tag").alias("tags"))

# Stampare lo schema e i primi 5 record del DataFrame dopo l'aggregazione dei tag
print("Schema del DataFrame dopo l'aggregazione dei tag:")
tags_dataset_agg.printSchema()

print("Primi 5 record del DataFrame dopo l'aggregazione dei tag:")
tags_dataset_agg.show(5)

# Chiudi la sessione Spark
spark.stop()
