setwd("C:/Users/mk693/OneDrive - University of Exeter/Desktop/2021/NIH/Data/miRNA-Seq")
library(stringr)
library(qpcR)
library(ggplot2)
#library(reshape)

InDir <- "10397_readlength/"
OutPrefix <- "10397"
splt <- 10

file_names <- list.files(path = InDir,pattern = ".txt",recursive = F,full.names = F)

data_ <- do.call(qpcR:::cbind.na,lapply(paste0(InDir,file_names),read.delim,header=F))

names(data_) <- str_remove(str_remove(file_names,pattern = "10397_"),pattern = "_R1_001_fastp2.fastq.gz_read_length.txt")

k <- ncol(data_)
w <- round(k/splt)

for (i in 1:(splt-1)) {
  a <- (i-1)*w+1
  b <- i*w
  png(filename = paste0(OutPrefix,"_reads",i,".png"),width = 800,height = 800)
  boxplot(data_[,c(a:b)],las = 2, names=colnames(data_[,c(a:b)]),par(mar = c(12, 5, 4, 2)+ 0.1))
  dev.off()
  print(paste0("i=",i,",Start=",a,", end=",b))
}

png(filename = paste0(OutPrefix,"_reads",splt,".png"),width = 800,height = 800)
boxplot(data_[,c(b:k)],las = 2, names=colnames(data_[,c(b:k)]),par(mar = c(12, 5, 4, 2)+ 0.1))
dev.off()
print(paste0("i=",splt,",Start=",b,", end=",k))
write.table(data_,file = paste0(OutPrefix,"read_len.tsv"),quote = F,row.names = F,col.names = T,sep = '\t')
