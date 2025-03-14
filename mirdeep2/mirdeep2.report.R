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
exprs.files = data.frame(ExprFile = basename(files_),Path =dirname( files_ ))
if(nrow(exprs.files) == 0){
  stop("No expression file were detected. Check the results directory: ",mirdeep.results.dir)
}else{
  message(nrow(exprs.files), " expression files were detected:")
  cat("\n")
}

exprs.files$ConfigFile <- NA
counts = vector(mode = "list" , length = nrow(exprs.files))

for (i in 1:nrow(exprs.files)) {
  
  message("Working on expression file ",i,"...")
  
  exprs.files$ConfigFile[i]= basename(list.files(path =exprs.files$Path[i],pattern = "config.*.txt",all.files = F,full.names = F, recursive = T,ignore.case = F))
  
  config <- read.delim(file = paste0(exprs.files$Path[i] , "/",exprs.files$ConfigFile[i]),header = F,stringsAsFactors = F,colClasses = c("character", "character"))
  expr <- read.delim(paste0(exprs.files$Path[i] , "/",exprs.files$ExprFile[i]))

  names(expr) <- str_remove(names(expr) , pattern = "X")
  index <- str_detect(names(expr) , pattern = "norm")
  expr <- expr[,!index]

  config[,1] <- basename(config[,1])
  index <- match(names(expr)[c(-1:-4)],config[,2])
  names(expr)[c(-1:-4)] <- config[index , 1]
  
  # write.csv(expr , file = paste0(dirname(OutPrefix),"/",exprs.files$ConfigFile[i],".count.csv"),row.names = F)
  mirna.ids = expr[,c(1,3)]
  names(mirna.ids) = c("miRNA" , "Precursor")
  expr = expr[,c(-1:-4)]
  counts[[i]] = expr
}


write.csv(exprs.files , file = paste0(OutPrefix , "mirdeep2.Config.Matched.csv"), row.names = F)

counts.merged = do.call(cbind.data.frame , c(mirna.ids , counts))

message("Writing merged count matrix...")
write.csv(counts.merged , file = paste0(OutPrefix,"mirdeep2.count.csv"),row.names = F)

