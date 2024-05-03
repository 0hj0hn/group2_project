.libPaths(c("/workspace/xlin285/hospital/Rlibs", .libPaths()))

library(data.table)
library(parallel)  

num_cores <- as.numeric(Sys.getenv("SLURM_CPUS_PER_TASK"))
if (is.na(num_cores) || num_cores == 0) {
  num_cores <- 8
}

args <- commandArgs(trailingOnly = TRUE)
hospital_data <- fread("archive/hospitals.csv")
price_data <- fread(args[1])  

hospital_data[, cms_certification_num := as.character(cms_certification_num)]
price_data[, cms_certification_num := as.character(cms_certification_num)]

price_data[, cms_certification_num := sprintf("%06d", as.numeric(cms_certification_num))]

merged_data <- merge(hospital_data, price_data, by = "cms_certification_num")

output_dirs <- c("pricing_strategy_splitted_parts", "payment_analysis_splitted_parts", "service_cost_analysis_splitted_parts")
lapply(output_dirs, function(dir) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }
})


states <- unique(merged_data$state)
pricing_strategy <- mclapply(states, function(state) {
  data_state <- merged_data[merged_data$state == state]
  summary_stats <- data_state[, .(
    Average_Price = mean(price, na.rm = TRUE),
    Min_Price = min(price, na.rm = TRUE),
    Max_Price = max(price, na.rm = TRUE)
  ), by = .(description)]
  return(summary_stats)
}, mc.cores = num_cores)
pricing_strategy <- rbindlist(pricing_strategy)


payers <- unique(merged_data$payer)
payment_analysis <- mclapply(payers, function(payer) {
  data_payer <- merged_data[merged_data$payer == payer]
  summary_stats <- data_payer[, .(
    Average_Price = mean(price, na.rm = TRUE),
    Payment_Count = .N
  ), by = .(description)]
  return(summary_stats)
}, mc.cores = num_cores)
payment_analysis <- rbindlist(payment_analysis)


descriptions <- unique(merged_data$description)
service_cost_analysis <- mclapply(descriptions, function(description) {
  data_service <- merged_data[merged_data$description == description]
  summary_stats <- data_service[, .(
    Average_Price = mean(price, na.rm = TRUE)
  ), by = .(inpatient_outpatient)]
  return(summary_stats)
}, mc.cores = num_cores)
service_cost_analysis <- rbindlist(service_cost_analysis)

filename_suffix <- gsub(".*part_([0-9]+)\\.csv$", "\\1", args[1])


fwrite(pricing_strategy, paste0("pricing_strategy_splitted_parts/part_", filename_suffix, ".csv"))
fwrite(payment_analysis, paste0("payment_analysis_splitted_parts/part_", filename_suffix, ".csv"))
fwrite(service_cost_analysis, paste0("service_cost_analysis_splitted_parts/part_", filename_suffix, ".csv"))
