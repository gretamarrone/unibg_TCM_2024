###### TEDx-Load-Aggregate-Model

import sys
import json
import pyspark
from pyspark.sql.functions import col, collect_list, array_join, explode
from pyspark.sql import SparkSession
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

###### READ PARAMETERS
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

##### START JOB CONTEXT AND JOB
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

##### FROM FILES
tedx_dataset_path = "s3://tcm-data-greta/final_list.csv"

#### READ INPUT FILES TO CREATE AN INPUT DATASET
tedx_dataset = spark.read.option("header","true").option("quote", "\"").option("escape", "\"").csv(tedx_dataset_path)
tedx_dataset.printSchema()

#### FILTER ITEMS WITH NULL POSTING KEY
count_items = tedx_dataset.count()
count_items_null = tedx_dataset.filter("id is not null").count()
print(f"Number of items from RAW DATA {count_items}")
print(f"Number of items from RAW DATA with NOT NULL KEY {count_items_null}")

tedx_dataset = tedx_dataset.select(col("id"), col("title"), col("url"))
tedx_dataset.printSchema()

## RELATED
related_videos_path = "s3://tcm-data-greta/related_videos.csv"
related_video_dataset = spark.read.option("header","true").option("quote", "\"").option("escape", "\"").csv(related_videos_path)
related_video_dataset = related_video_dataset.select(col("id").alias("id_from"), 
    col("related_id").alias("id_related"), 
    col("title").alias("title_related")) 
related_video_dataset.printSchema()
related_video_dataset.show()

## JOIN con i details
##solo uno id_related??
tedx_dataset = tedx_dataset.join(related_video_dataset, tedx_dataset.id == related_video_dataset.id_from, "left") \
    .drop("id_from") \
    .select(col("id").alias("idref"), col("title"), col("url"), col("id_related"), col("title_related"))
tedx_dataset.printSchema()
tedx_dataset.show()


## READ THE TAGS
tags_dataset_path = "s3://tcm-data-greta/tags.csv"
tags_dataset = spark.read.option("header","true").option("quote", "\"").option("escape", "\"").csv(tags_dataset_path)
tags_dataset = tags_dataset.select(col("id"), col("tag")) 

tags_dataset.printSchema()
tags_dataset.show()

    
tags_dataset = tags_dataset.groupBy("id") \
    .agg(collect_list(col("tag")).alias("tag_related"))
tags_dataset.printSchema()
tags_dataset.show()


# Controlla i dati di id_related e id
tedx_dataset.select("id_related").distinct().show()
tags_dataset.select("id").distinct().show()

# Verifica se ci sono valori nulli in id_related
tedx_dataset.filter(col("id_related").isNull()).show()

# Esegui la join assicurandoti che non ci siano valori nulli in id_related
tedx_dataset = tedx_dataset.filter(col("id_related").isNotNull())




# Join tra i tag e i video DEVE ESSERE IDREL
tedx_dataset = tedx_dataset.join(tags_dataset, tedx_dataset.id_related == tags_dataset.id, "left") \
    .select(tedx_dataset.idref,
    tedx_dataset.title, 
    tedx_dataset.url, 
    tedx_dataset.id_related, 
    tedx_dataset.title_related, 
    tags_dataset.tag_related)

    
tedx_dataset.printSchema()
tedx_dataset.show(truncate=False)

# Verifica se la join ha funzionato correttamente
tedx_dataset.filter(col("tag_related").isNotNull()).show()
tedx_dataset.filter(col("tag_related").isNull()).show()

# Filtra le righe con valori nulli in id_related
tedx_dataset_filtered = tedx_dataset.filter(col("tag_related").isNotNull())
tedx_dataset_filtered.show()

# Raggruppa per id
tedx_grouped = tedx_dataset_filtered.groupBy("idref", "title", "url") \
    .agg(collect_list("id_related").alias("id_related"),
    collect_list("title_related").alias("title_related"),
    collect_list("tag_related").alias("tag_related"))

tedx_grouped= tedx_grouped.withColumnRenamed("idref", "_id")


tedx_grouped.printSchema()
tedx_grouped.show()


write_mongo_options = {
    "connectionName": "TCM_TEDX",
    "database": "tcm_tedx_2024",
    "collection": "tedx_related_tags",
    "ssl": "true",
    "ssl.domain_match": "false"}
from awsglue.dynamicframe import DynamicFrame
tedx_dataset_dynamic_frame = DynamicFrame.fromDF(tedx_grouped, glueContext, "nested")
glueContext.write_dynamic_frame.from_options(tedx_dataset_dynamic_frame, connection_type="mongodb", connection_options=write_mongo_options)
