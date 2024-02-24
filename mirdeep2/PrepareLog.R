library(stringr)
setwd(".")
log_data <- read.delim(file = "10397/10397_mideep2.log",check.names = F)
config_data <- read.delim(file = "10397/project_10397_config.txt",check.names = F,header = F)

config_data$sample_name <- str_remove(config_data$V1,pattern = "/home/ubuntu/data/miRNA/10397/10397_")
config_data$sample_name <- str_remove(config_data$sample_name,pattern = "_R1_001_fastp2.fastq")
config_data$V2[1:9] <- paste0("00",config_data$V2[1:9])
config_data$V2[10:99] <- paste0("0",config_data$V2[10:99])

index <- match(config_data$V2,log_data$desc)
identical(log_data$desc[index],config_data$V2)
log_data$sample_name <- NA
log_data$sample_name[index] <- config_data$sample_name

write.csv(log_data,file = "log.mirdeep.10397.csv",row.names = F)
