# install the packages
install.packages("sparklyr")
install.packages("dplyr")

# Load necessary packages
library(sparklyr)
library(dplyr)

# Main function
main <- function() {
  # Connect to Spark locally
  sc <- spark_connect(
    master = "local[*]", 
    version = "3.5.2", 
    spark_home = "C:/Users/PLIU/Documents/Tool/spark/spark-3.5.2",
    app_name = "WordCount")
  
  # Set data path
  file_path <- "../data/le_petit_prince.txt"
  
  # Read text file into DataFrame
  df <- spark_read_text(sc, "text_data", file_path)
  
  # Process the text and count words
  word_counts <- df %>%
    # Split text into words, explode and convert to lowercase
    ft_tokenizer(input_col = "line", output_col = "words") %>%
    mutate(words = lower(words)) %>%
    sdf_explode(column = "words", output_col = "word") %>%
    # Filter out empty strings
    filter(word != "") %>%
    # Count word occurrences
    group_by(word) %>%
    summarize(count = n()) %>%
    # Sort by frequency
    arrange(desc(count))
  
  # Show top 20 most frequent words
  word_counts %>% 
    head(20) %>%
    collect() %>%
    print()
  
  # Save results if needed
  output_file_path <- "../data/out/le_petit_prince_count.txt"
  spark_write_csv(word_counts, output_file_path)
  
  # Disconnect from Spark
  spark_disconnect(sc)
}

# Execute the main function
main()