###############################################################################################################
##                                                                                                           ##
## Script to combine pipeline runs for individual samples into something more useful                         ##
##                                                                                                           ##
## Author: Rob Kitchen (r.r.kitchen@gmail.com)                                                               ##
##                                                                                                           ##
## Version 3.2.0 (2015-11-02)                                                                                ##
##                                                                                                           ##
## Modified by Morteza Kouhsar (m.kouhsar@exeter.ac.uk) to extract other RNA types from the GENCODE results  ##
##                                                                                                           ##
###############################################################################################################
## requireed R packages:
##   plyr
##   gplots
##   marray
##   reshape2
##   ggplot2
##   tools
##   Rgraphviz
##   scales
##   stringr
##   tidyverse

##
## Check inputs
##
args<-commandArgs(TRUE)
if(length(args) == 0){
  
  ## if no data directory is specified, throw an error message
  cat("\nERROR: no input data directory specified!\n\n")
  cat("Usage: Rscript mergePipelineRuns.R <data path> [output path]\n\n")

}else{
  
  data.dir = args[1]
  if(length(args) >= 2){
    output.dir = args[2]
    if(length(args) == 3){
      classifier.path = args[3]
    }
  }else{
    output.dir = data.dir
  }
  
  
  ##
  ## Find the relative path to the script containing the required functions
  ##
  initial.options <- commandArgs(trailingOnly = FALSE)
  file.arg.name <- "--file="
  script.name <- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])
  script.basename <- dirname(script.name)
  if(length(script.basename) > 0){
	  other.name <- paste(sep="/", script.basename, "mergePipelineRuns_functions.R")
  }else{
	  other.name = "mergePipelineRuns_functions.R"
  }
  print(paste("Sourcing",other.name,"from",script.basename))
  source(other.name)
  cat("\n")
  
  
  ##
  ## Process all samples under this directory
  ##
  processSamplesInDir(data.dir, output.dir, scriptDir=script.basename)
}
################################################################################
suppressMessages(library(tidyverse))
load(paste0(output.dir,"exceRpt_smallRNAQuants_ReadCounts.RData"))

exprs.gencode <- as.data.frame(exprs.gencode) %>%
  rownames_to_column("rowname") %>%
  separate(rowname, into = c("gene_id", "gene_type"), sep = ":")

exprs.gencode_list <- split(exprs.gencode, exprs.gencode$gene_type)
dir.create(paste0(output.dir,"/gencodeRNAs"))
for(i in 1: length(exprs.gencode_list)){
  write.table(exprs.gencode_list[[i]] , file = paste0(output.dir,"/gencodeRNAs/",
                                                            names(exprs.gencode_list)[i] , "_ReadCount.tsv"),
              row.names = F , col.names = T , quote = F , sep = "\t")
}

load(paste0(output.dir,"exceRpt_smallRNAQuants_ReadsPerMillion.RData"))

exprs.gencode.rpm <- as.data.frame(exprs.gencode.rpm) %>%
  rownames_to_column("rowname") %>%
  separate(rowname, into = c("gene_id", "gene_type"), sep = ":")

exprs.gencode.rpm_list <- split(exprs.gencode.rpm, exprs.gencode.rpm$gene_type)
dir.create(paste0(output.dir,"/gencodeRNAs"))
for(i in 1: length(exprs.gencode.rpm_list)){
  write.table(exprs.gencode.rpm_list[[i]] , file = paste0(output.dir,"/gencodeRNAs/",
                                                                names(exprs.gencode.rpm_list)[i] , "_ReadPerMillion.tsv"),
              row.names = F , col.names = T , quote = F , sep = "\t")
}
