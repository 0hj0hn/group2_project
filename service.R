.libPaths(c("/workspace/xlin285/hospital/Rlibs", .libPaths()))
library(data.table)
library(parallel)
library(gridExtra)

output_file <- "sampled_service_cost_analysis.csv"

if (!file.exists(output_file)) {

    folder_path <- "service_cost_analysis_splitted_parts"
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
    sampled_data <- fread(output_file)
}


p1 <- ggplot(sampled_data, aes(x=Average_Price)) +
  geom_histogram(binwidth = 200, fill = "blue", color = "black") +
  facet_wrap(~inpatient_outpatient) +
  labs(title="Histogram of Average Prices by Type", x="Average Price", y="Count") +
  theme_minimal()


p2 <- ggplot(sampled_data, aes(x=Average_Price, fill=inpatient_outpatient)) +
  geom_density(alpha = 0.6) +
  labs(title="Density Plot of Average Prices by Type", x="Average Price", y="Density") +
  theme_minimal()


grid.arrange(p1, p2, ncol=1)