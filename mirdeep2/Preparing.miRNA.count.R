library(stringr)

args <- commandArgs(T)

mirdeep.results.dir <- args[1] # The directory contains mirdeep2 results
OutPrefix <- args[2]           # This script Output files prefix
SampleID.trim <- args[3]       # The substring that you want to remove from the samples IDs in the count matrix (e.g. ".fastq")

if(is.na(OutPrefix)){
  OutPrefix = ""
}else{
  OutPrefix = paste0(OutPrefix , ".")
}

if(is.na(mirdeep.results.dir)){
  mirdeep.results.dir = "."
}

message("mirdeep2 results directory: ", mirdeep.results.dir)
message("Count matrix files prefix: ", OutPrefix)
message("The following substring will be removed from the sample IDs: ", SampleID.trim)
cat("\n")

message("Detecting expression files...")

exprs.files = data.frame(ExprFile = list.files(path = mirdeep.results.dir , pattern = "^miRNAs_expressed_all_samples_.*[.]csv",
                                               all.files = F,full.names = F, recursive = T,ignore.case = F))
if(nrow(exprs.files) == 0){
  stop("No expression file were detected. Check the results directory: ",mirdeep.results.dir)
}else{
  message(nrow(exprs.files), " expression files were detected:")
  cat("\n")
}
exprs.files$ConfigFile = NA
counts = vector(mode = "list" , length = nrow(exprs.files))

for (i in 1:nrow(exprs.files)) {
  
  message("Working on expression file ",i,"...")

  mirdeep.name = str_remove(exprs.files$ExprFile[i] , pattern = ".csv")
  mirdeep.name = str_remove(mirdeep.name , pattern = "miRNAs_expressed_all_samples_")
  config.path = paste0(mirdeep.results.dir , "/expression_analyses/expression_analyses_",mirdeep.name)
  f = list.files(path = config.path , pattern = ".*fa_mapped.arf",
                all.files = F,full.names = F, recursive = F,ignore.case = F)
  exprs.files$ConfigFile[i] = paste0(str_remove(f , pattern = "fa_mapped.arf"),"config")



  config_file = paste0(mirdeep.results.dir , "/",exprs.files$ConfigFile[i])
  expr_file = paste0(mirdeep.results.dir , "/",exprs.files$ExprFile[i])

  config <- read.delim(file = config_file,header = F,stringsAsFactors = F,colClasses = c("character", "character"))
  expr <- read.delim(expr_file)

  names(expr) <- str_remove(names(expr) , pattern = "X")
  index <- str_detect(names(expr) , pattern = "norm")
  expr <- expr[,!index]

  config[,1] <- basename(config[,1])
  index <- match(names(expr)[c(-1:-4)],config[,2])
  names(expr)[c(-1:-4)] <- config[index , 1]
  
  if(!is.na(SampleID.trim)){
    names(expr) = str_remove(names(expr) , pattern = SampleID.trim)
  }
  
  write.csv(expr , file = paste0(dirname(OutPrefix),"/",exprs.files$ConfigFile[i],".count.csv"),row.names = F)
  mirna.ids = expr[,c(1,3)]
  names(mirna.ids) = c("miRNA" , "Precursor")
  expr = expr[,c(-1:-4)]
  counts[[i]] = expr
}


write.csv(exprs.files , file = paste0(OutPrefix , "mirdeep2.Config.Matched.csv"), row.names = F)

counts.merged = do.call(cbind.data.frame , c(mirna.ids , counts))

message("Writing merged count matrix...")
write.csv(counts.merged , file = paste0(OutPrefix,"mirdeep2.count.csv"),row.names = F)

