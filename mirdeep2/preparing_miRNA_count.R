library(stringr)
library(vroom)
args <- commandArgs(T)

#input_dir <- args[1]
expr_file <- args[1]
config_file <- args[2]
out_prefix <- args[3]


config <- read.delim(file = config_file,header = F,stringsAsFactors = F,colClasses = c("character", "character"))

#files <- list.files(path=input_dir,pattern="miRNAs_expressed_all_samples_(.)*.csv", full.names = T)

#f <- read.delim(files[1])[,c(-2,-4)]
f <- read.delim(expr_file)
names(f) <- str_remove(names(f) , pattern = "X")
index <- str_detect(names(f) , pattern = "norm")
f <- f[,!index]

#expr <- list()
#expr[[1]] <- f

#for (i in 2:length(files)) {
 # f <- read.delim(files[i])[,c(-1:-4)]
  #names(f) <- str_remove(names(f) , pattern = "X")
  #index <- str_detect(names(f) , pattern = "norm")
  #f <- f[,!index]
  #expr[[i]] <- f
#}
#expr1 <- do.call(cbind.data.frame,expr)
expr1 <- f

config[,1] <- basename(config[,1])
index <- match(names(expr1)[c(-1:-4)],config[,2])
names(expr1)[c(-1:-4)] <- config[index , 1]

write.csv(expr1 , file = paste0(out_prefix,".csv"),row.names = F)
