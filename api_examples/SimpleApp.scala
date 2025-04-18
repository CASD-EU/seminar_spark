import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._

object WordCountApp {
  def main(args: Array[String]): Unit = {
    // Initialize SparkSession
    val spark = SparkSession.builder()
      .appName("WordCount")
      .master("local[*]") 
      .getOrCreate()

    // Data path
    val filePath = "../data/le_petit_prince.txt"

    // Read text file into DataFrame
    val df = spark.read.text(filePath)

    // Word count logic
    val wordCounts = df
      .select(explode(split(lower(col("value")), "\\s+")).alias("word"))
      .filter(col("word") =!= "")
      .groupBy("word")
      .agg(count("*").alias("count"))
      .orderBy(desc("count"))

    // Show top 20 most frequent words
    wordCounts.show(20)

    // Save results
    val outputPath = "../data/out/le_petit_prince_count.txt"
    wordCounts.write.option("header", "true").csv(outputPath)

    spark.stop()
  }
}