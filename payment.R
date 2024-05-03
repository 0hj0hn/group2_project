.libPaths(c("/workspace/xlin285/hospital/Rlibs", .libPaths()))
library(data.table)
library(parallel)
library(gridExtra)
library(ggplot2)
library(dplyr)

output_file <- "sampled_payment_data.csv"

if (!file.exists(output_file)) {
  folder_path <- "payment_analysis_splitted_parts"
  csv_files <- list.files(path = folder_path, pattern = "\\.csv$", full.names = TRUE)
  sample_func <- function(file) {
    dt <- fread(file, nrows = 6000)
    return(dt)
  }
  
  cores_to_use <- max(1, detectCores() / 2)

  sampled_data_list <- mclapply(csv_files, sample_func, mc.cores = cores_to_use)
  sampled_data <- rbindlist(sampled_data_list, use.names = TRUE, fill = TRUE)
  
  fwrite(sampled_data, file = output_file)
  message("Sampled data saved to ", output_file)
} else {
  sampled_data <- fread(output_file)
}

hexbin_plot <- ggplot(sampled_data, aes(x=Average_Price, y=Payment_Count)) +
  geom_hex(bins=50) +
  scale_fill_viridis_c(option="C") +
  labs(title="Hexbin Plot of Payment Count vs. Average Price (Log Scale)",
       x="Average Price (Log Scale)",
       y="Payment Count (Log Scale)") +
  theme_minimal() +
  scale_x_log10() +  
  scale_y_log10()    


frequency <- sampled_data %>% 
  group_by(description) %>% 
  summarise(count = n()) %>% 
  arrange(desc(count)) %>% 
  top_n(3, count)

filtered_data <- sampled_data %>% 
  filter(description %in% frequency$description)


violin_plot <- ggplot(filtered_data, aes(x=description, y=Average_Price, fill=description)) +
  geom_violin(trim=FALSE) +
  scale_fill_brewer(palette="Pastel1") +  
  labs(title="Violin Plot of Average Prices by Top 3 Conditions") +
  theme_minimal() +
  theme(legend.position = "bottom")


grid.arrange(hexbin_plot, violin_plot, ncol=1)
