import sys
import json
import pyspark
from pyspark.sql.functions import col, collect_list, count, asc
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

##### FROM FILES
tedx_dataset_path = "s3://tcm-data-greta/tags.csv"

###### READ PARAMETERS
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

##### START JOB CONTEXT AND JOB
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

#### READ INPUT FILES TO CREATE AN INPUT DATASET
tedx_dataset = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(tedx_dataset_path)

tedx_dataset = tedx_dataset.select(col("tag").alias("tags"), col("id"))

tedx_dataset.printSchema()
tedx_dataset.show()

#### FILTER ITEMS WITH NULL POSTING KEY
count_items = tedx_dataset.count()
count_items_null = tedx_dataset.filter("id is not null").count()

print(f"Number of items from RAW DATA {count_items}")
print(f"Number of items from RAW DATA with NOT NULL KEY {count_items_null}")

## READ THE DETAILS
details_dataset_path = "s3://tcm-data-greta/final_list.csv"
details_dataset = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(details_dataset_path)

details_dataset = details_dataset.select(col("id").alias("id_ref"),
                                         col("title"),
                                         col("url"))
details_dataset.show()

# AND JOIN WITH THE MAIN TABLE
tedx_dataset = tedx_dataset.join(details_dataset, tedx_dataset.id == details_dataset.id_ref, "left") \
    .drop("id_ref")

tedx_dataset.printSchema()

# REMOVE DUPLICATES
tedx_dataset = tedx_dataset.dropDuplicates(["id", "tags", "title", "url"])

tedx_dataset.show()

# GROUP BY TAG AND AGGREGATE
grouped_tedx_dataset = tedx_dataset.groupBy("tags").agg(
    count("id").alias("count"),
    collect_list("title").alias("titles"),
    collect_list("url").alias("urls"),
    collect_list("id").alias("ids")
)

# Sort the aggregated data by "tags"
grouped_tedx_dataset = grouped_tedx_dataset.orderBy("tags")

grouped_tedx_dataset.printSchema()

write_mongo_options = {
    "connectionName": "TCM_TEDX",
    "database": "tcm_tedx_2024",
    "collection": "tedx_tags",
    "ssl": "true",
    "ssl.domain_match": "false"}

from awsglue.dynamicframe import DynamicFrame
grouped_tedx_dataset_dynamic_frame = DynamicFrame.fromDF(grouped_tedx_dataset, glueContext, "nested")

glueContext.write_dynamic_frame.from_options(grouped_tedx_dataset_dynamic_frame, connection_type="mongodb", connection_options=write_mongo_options)