from pyspark.sql import SparkSession
from pyspark.sql.functions import explode, split, lower, col, count


def main():
    # Initialize a Spark Session
    spark = SparkSession.builder \
        .appName("WordCount") \
        .getOrCreate()

    # data path
    file_path = "../data/le_petit_prince.txt"
    # Read text file into DataFrame
    # Each line becomes a row in the DataFrame
    df = spark.read.text(file_path)

    # Process the text and count words
    word_counts = df \
        .select(explode(split(lower(col("value")), "\\s+")).alias("word")) \
        .filter(col("word") != "") \
        .groupBy("word") \
        .count() \
        .orderBy("count", ascending=False)

    # Show top 20 most frequent words
    word_counts.show(20)

    # Save results if needed
    output_file_path = "../data/out/le_petit_prince_count.txt"
    word_counts.write.csv(output_file_path, header=True)

    spark.stop()


if __name__ == "__main__":
    main()