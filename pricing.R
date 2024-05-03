.libPaths(c("/workspace/xlin285/hospital/Rlibs", .libPaths()))
library(data.table)
library(ggplot2)
library(gridExtra)


output_file <- "sampled_pricing_data.csv"


if (!file.exists(output_file)) {

  folder_path <- "pricing_strategy_splitted_parts"
  csv_files <- list.files(path = folder_path, pattern = "\\.csv$", full.names = TRUE)
  
  sample_func <- function(file) {
    dt <- fread(file)  
    n <- min(6000, nrow(dt))
    sampled_rows <- dt[sample(.N, n)]
    return(sampled_rows)
  }
  
  sampled_data_list <- mclapply(csv_files, sample_func, mc.cores = detectCores())
  
  sampled_data <- rbindlist(sampled_data_list, use.names = TRUE, fill = TRUE)
  
  fwrite(sampled_data, file = output_file)
  message("Sampled data saved to ", output_file)
} else {
  
}

sampled_data <- fread(output_file, fill = TRUE, colClasses = list(numeric = c("Average_Price", "Min_Price", "Max_Price")), showProgress = TRUE)


numeric_columns <- c("Average_Price", "Min_Price", "Max_Price")
sampled_data[, (numeric_columns) := lapply(.SD, as.numeric), .SDcols = numeric_columns]


desc_freq <- table(sampled_data$description)
top_desc <- names(desc_freq)[which.max(desc_freq)]


sampled_data_top_desc <- sampled_data[sampled_data$description %in% top_desc, ]


desc_freq <- table(sampled_data$description)
top_desc <- names(desc_freq)[which.max(desc_freq)]


sampled_data_top_desc <- sampled_data[sampled_data$description %in% top_desc, ]


p <- ggplot(sampled_data_top_desc, aes(x = factor(0))) +
  geom_boxplot(aes(y = Average_Price, fill = "Average Price")) +
  geom_boxplot(aes(y = Min_Price, fill = "Min Price")) +
  geom_boxplot(aes(y = Max_Price, fill = "Max Price")) +
  scale_fill_manual(values = c("Average Price" = "cornflowerblue", 
                               "Min Price" = "coral", 
                               "Max Price" = "mediumseagreen"),
                    name = "Price Type") + 
  labs(title = paste("Price Comparison for", top_desc),
       x = NULL, y = "Price") +
  theme_minimal() + 
  theme(axis.text.x = element_blank(), 
        axis.ticks.x = element_blank(),
        legend.position = "bottom")


print(p)