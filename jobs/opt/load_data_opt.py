import sys
import pyspark
from pyspark.sql.functions import col, collect_list, count, log
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# READ PARAMETERS
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# START JOB CONTEXT AND JOB
sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Utility function for reading CSV
def read_csv(path, options={}):
    return spark.read.options(**options).csv(path)

# File paths
tedx_dataset_path = "s3://tedx-2024-data-greta/final_list.csv"
details_dataset_path = "s3://tedx-2024-data-greta/details.csv"
images_dataset_path = "s3://tedx-2024-data-greta/images.csv"
related_videos_path = "s3://tedx-2024-data-greta/related_videos.csv"
tags_dataset_path = "s3://tedx-2024-data-greta/tags.csv"

csv_options = {
    "header": "true",
    "quote": "\"",
    "escape": "\""
}

# Read datasets
tedx_dataset = read_csv(tedx_dataset_path, csv_options)
details_dataset = read_csv(details_dataset_path, csv_options)
images_dataset = read_csv(images_dataset_path, csv_options)
related_video_dataset = read_csv(related_videos_path, csv_options)
tags_dataset = read_csv(tags_dataset_path, {"header": "true"})

# Filter and count items
count_items_null = tedx_dataset.filter("id is not null").count()
count_items = tedx_dataset.count()

print(f"Number of items from RAW DATA {count_items}")
print(f"Number of items from RAW DATA with NOT NULL KEY {count_items_null}")

# Select relevant columns from TEDx dataset
tedx_dataset = tedx_dataset.select(col("id"), col("title"), col("url"))

# Join TEDx dataset with details dataset
details_dataset = details_dataset.select(col("id").alias("id_ref"), "description", "duration", "publishedAt")
tedx_dataset = tedx_dataset.join(details_dataset, tedx_dataset.id == details_dataset.id_ref, "left").drop("id_ref")

# Join TEDx dataset with images dataset
images_dataset = images_dataset.select(col("id").alias("id_ref"), col("url").alias("image_url"))
tedx_dataset = tedx_dataset.join(images_dataset, tedx_dataset.id == images_dataset.id_ref, "left").drop("id_ref")

# Process related video dataset
related_video_dataset = related_video_dataset.select(
    col("id").alias("id_from"), 
    col("related_id").alias("id_related"), 
    col("title").alias("title_related")
)

# Join TEDx dataset with related videos
tedx_dataset = tedx_dataset.join(
    related_video_dataset, tedx_dataset.id == related_video_dataset.id_from, "left"
).drop("id_from")

# Read and process tags dataset
tags_dataset = tags_dataset.select(col("id"), col("tag"))
tags_dataset_current = tags_dataset.groupBy("id").agg(collect_list(col("tag")).alias("tag_current"))
tags_dataset_related = tags_dataset.groupBy("id").agg(collect_list(col("tag")).alias("tag_related"))
tedx_dataset = tedx_dataset.join(tags_dataset_current, tedx_dataset.id == tags_dataset_current.id, "left").drop("id")


# Filter non-null related IDs
tedx_dataset = tedx_dataset.filter(col("id_related").isNotNull())

# Join TEDx dataset with tags
tedx_dataset = tedx_dataset.join(
    tags_dataset, tedx_dataset.id_related == tags_dataset.id, "left"
).select(
    tedx_dataset.id.alias("idref"),
    tedx_dataset.title,
    tedx_dataset.url,
    tedx_dataset.id_related,
    tedx_dataset.title_related,
    tedx_dataset.tag_current,
    tags_dataset_related.tag_related)

# Filter rows with non-null tags
tedx_dataset_filtered = tedx_dataset.filter(col("tag_related").isNotNull())

# Group by ID and aggregate lists
tedx_grouped = tedx_dataset_filtered.groupBy("idref", "title", "url", "tag_current").agg(
    collect_list("id_related").alias("id_related"),
    collect_list("title_related").alias("title_related"),
    collect_list("tag_related").alias("tag_related")
)

# Rename column for MongoDB compatibility
tedx_grouped = tedx_grouped.withColumnRenamed("idref", "_id")



#-------
# Calculate TF
tags_with_details = tags_dataset.join(details_dataset, tags_dataset.id == details_dataset.id_ref, "left") \
    .drop("id_ref") \
    .dropDuplicates(["id", "tags", "title", "url"])
tf_tedx_dataset = tags_with_details.groupBy("id", "tags").count().withColumnRenamed("count", "tf")

# Calculate IDF
df_tedx_dataset = tedx_dataset.groupBy("tags").agg(count("id").alias("df"))
N = tedx_dataset.select("id").distinct().count()
df_tedx_dataset = df_tedx_dataset.withColumn("idf", log(N / col("df")))

# Join TF and IDF to calculate TF-IDF
tf_idf_tedx_dataset = tf_tedx_dataset.join(df_tedx_dataset, "tags") \
    .withColumn("tf_idf", col("tf") * col("idf"))

# Rejoin with the original dataset to include title and URL
tf_idf_tedx_dataset = tf_idf_tedx_dataset.join(tags_with_details.select("id", "tags", "title", "url"), on=["id", "tags"])

# Group by tag and aggregate
grouped_tedx_dataset = tf_idf_tedx_dataset.groupBy("tags").agg(
    count("id").alias("count"),
    collect_list("title").alias("titles"),
    collect_list("url").alias("urls"),
    collect_list("id").alias("ids"),
    collect_list("tf_idf").alias("tf_idfs")
)

# Sort the aggregated data by "tags"
grouped_tedx_dataset = grouped_tedx_dataset.orderBy("tags")

grouped_tedx_dataset.printSchema()

# Write to MongoDB
from awsglue.dynamicframe import DynamicFrame

write_mongo_options = {
    "connectionName": "TEDX2024",
    "database": "unibg_tedx_2024",
    "collection": "tedx_data",
    "ssl": "true",
    "ssl.domain_match": "false"
}

tedx_dataset_dynamic_frame = DynamicFrame.fromDF(grouped_tedx_dataset, glueContext, "nested")
glueContext.write_dynamic_frame.from_options(
    tedx_dataset_dynamic_frame, 
    connection_type="mongodb", 
    connection_options=write_mongo_options
)
