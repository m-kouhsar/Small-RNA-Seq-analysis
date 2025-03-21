library(stringr)

args <- commandArgs(T)

mirdeep.results.dir <- args[1] # The directory contains mirdeep2 results
OutPrefix <- args[2]           # This script Output files prefix

if(is.na(OutPrefix)){
  OutPrefix = ""
}else{
  OutPrefix = paste0(OutPrefix , "_")
}

if(is.na(mirdeep.results.dir)){
  mirdeep.results.dir = "."
}

message("mirdeep2 results directory: ", mirdeep.results.dir)
message("Count matrix files prefix: ", OutPrefix)
cat("\n")

message("Detecting expression files...")

files_ <- list.files(path = mirdeep.results.dir , pattern = "^miRNAs_expressed_all_samples_.*[.]csv",
                     all.files = F,full.names = T, recursive = T,ignore.case = F)
results.files = data.frame(ExprFile = basename(files_),Path =dirname( files_ ))
if(nrow(results.files) == 0){
  stop("No expression file were detected. Check the results directory: ",mirdeep.results.dir)
}else{
  message(nrow(results.files), " expression files were detected:")
  cat("\n")
}

results.files$ConfigFile <- NA
results.files$LogFile <- NA
counts = vector(mode = "list" , length = nrow(results.files))
report = vector(mode = "list" , length = nrow(results.files))

for (i in 1:nrow(results.files)) {
  
  message("Working on expression file ",i,"...")
  
  results.files$ConfigFile[i]= basename(list.files(path =results.files$Path[i],pattern = "config.*.txt",all.files = F,full.names = F, recursive = F,ignore.case = F))
  results.files$LogFile[i]= basename(list.files(path =results.files$Path[i],pattern = "mirdeep2.*.log",all.files = F,full.names = F, recursive = F,ignore.case = F))
  
  config <- read.delim(file = paste0(results.files$Path[i] , "/",results.files$ConfigFile[i]),header = F,stringsAsFactors = F,colClasses = c("character", "character"))
  expr <- read.delim(paste0(results.files$Path[i] , "/",results.files$ExprFile[i]))
  log_ <- read.table(paste0(results.files$Path[i] , "/",results.files$LogFile[i]), sep = "\n", comment.char = "")[,1]

  names(expr) <- str_remove(names(expr) , pattern = "X")
  index <- str_detect(names(expr) , pattern = "norm")
  expr <- expr[,!index]

  config[,1] <- basename(config[,1])
  index <- match(names(expr)[c(-1:-4)],config[,2])
  names(expr)[c(-1:-4)] <- config[index , 1]
  
  mirna.ids = expr[,c(1,3)]
  names(mirna.ids) = c("miRNA" , "Precursor")
  expr = expr[,c(-1:-4)]
  counts[[i]] = expr
  
  log_ <- log_[35:(35+nrow(config)+1)]
  log_ <- str_replace(log_ , pattern = ": ",replacement = "\t")
  log_ <- do.call(rbind,lapply(log_,str_split_1,pattern="\t"))
  colnames(log_) <- log_[1,]
  log_ <- as.data.frame(log_[c(-1,-2),])
  names(log_) <- c("sample","total_reads","mapped_reads","unmapped_reads","mapped_reads_perc","unmapped_reads_perc")
  
  index <- match(log_$sample,config[,2])
  log_$sample <- config[index , 1]
  
  report[[i]] <- log_
}

if(!dir.exists(dirname(OutPrefix))){
  dir.create(dirname(OutPrefix))
}

message("Writing merged results...")
write.csv(results.files , file = paste0(OutPrefix , "mirdeep2.config.matched.csv"), row.names = F)

counts.merged = do.call(cbind.data.frame , c(mirna.ids , counts))
logs.merged = do.call(rbind.data.frame , report)

write.csv(counts.merged , file = paste0(OutPrefix,"mirdeep2.count.csv"),row.names = F)
write.csv(logs.merged , file = paste0(OutPrefix,"mirdeep2.report.csv"),row.names = F)
