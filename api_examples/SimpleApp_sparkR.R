spark_home <- "C:/Users/PLIU/Documents/Tool/spark/spark-3.5.2" 
install.packages(paste0(spark_home, "/R/lib/SparkR"), repos = NULL, type = "source")

# Load sparkR libraries
library(SparkR)

main <- function() {
  # Initialize a Spark Session
  sparkR.session(appName = "WordCount", master="local[*]")
  
  # data path
  file_path <- "../data/le_petit_prince.txt"
  
  # Read text file into DataFrame
  # Each line becomes a row in the DataFrame
  df <- read.text(file_path)
  
  # Process the text and count words
  # Split the text into words
  words_df <- selectExpr(df, "explode(split(lower(value), '\\\\s+')) as word")
  
  # Filter out empty strings and count occurrences
  word_counts <- words_df %>%
    filter(words_df$word != "") %>%
    groupBy("word") %>%
    count() %>%
    arrange(desc(column("count")))
  
  # Show top 20 most frequent words
  showDF(word_counts, numRows = 20)
  
  # Save results if needed
  output_file_path <- "../data/out/le_petit_prince_count.txt"
  write.csv(word_counts, output_file_path, header = TRUE)
  
  # Stop the Spark session
  sparkR.session.stop()
}

# Execute the main function
main()
