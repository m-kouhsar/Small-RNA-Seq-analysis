args<-commandArgs(T)

InDir <- args[1]
OutDir <- args[2]
Prefix <- args[3]

library(stringr)

dirs <- list.dirs(path =InDir,recursive = F)

tRNA <- list()
piRNA <- list()
miRNA <- list()
tRNA_id <- vector(mode="character")
piRNA_id <- vector(mode="character")
miRNA_id <- vector(mode="character")
for (i in 1:length(dirs)){
  print(i)
  file1 <- paste0(dirs[i],"/readCounts_tRNA_sense.txt")
  file2 <- paste0(dirs[i],"/readCounts_tRNA_antisense.txt")
  file3 <- paste0(dirs[i],"/readCounts_piRNA_sense.txt")
  file4 <- paste0(dirs[i],"/readCounts_piRNA_antisense.txt")
  file5 <- paste0(dirs[i],"/readCounts_miRNAmature_sense.txt")
  file6 <- paste0(dirs[i],"/readCounts_miRNAmature_antisense.txt")
  
  if(file.exists(file1)){
    trna_sense <- read.delim(file = file1)
  }else
    trna_sense <- matrix(data=NA,nrow=0,ncol=5)
  
  if(file.exists(file2)){
    trna_antisense <- read.delim(file =file2 )
  }else
    trna_antisense <- matrix(data=NA,nrow=0,ncol=5)
    
  if(file.exists(file3)){
    pirna_sense <- read.delim(file =file3 )
  }else
    pirna_sense <- matrix(data=NA,nrow=0,ncol=5)
  
  if(file.exists(file4)){
    pirna_antisense <- read.delim(file =file4 )
  }else
    pirna_antisense <- matrix(data=NA,nrow=0,ncol=5)
    
  if(file.exists(file5)){
    mirna_sense <- read.delim(file =file5 )
  }else
    mirna_sense <- matrix(data=NA,nrow=0,ncol=5)
    
  if(file.exists(file6)){
    mirna_antisense <- read.delim(file =file6 )
  }else
    mirna_antisense <- matrix(data=NA,nrow=0,ncol=5)
  
  trna_all <- rbind.data.frame(trna_sense,trna_antisense)
  tRNA_id <- append(tRNA_id,trna_all$ReferenceID)
  tRNA_id <- unique(tRNA_id)
  
  pirna_all <- rbind.data.frame(pirna_sense,pirna_antisense)
  piRNA_id <- append(piRNA_id,pirna_all$ReferenceID)
  piRNA_id <-unique(piRNA_id)
  
  mirna_all <- rbind.data.frame(mirna_sense,mirna_antisense)
  miRNA_id <- append(miRNA_id,mirna_all$ReferenceID)
  miRNA_id <-unique(miRNA_id)
  
  tRNA[[i]] <- trna_all
  piRNA[[i]] <- pirna_all
  miRNA[[i]] <- mirna_all
}

tRNA_count <- as.data.frame(matrix(data=0 , nrow=length(tRNA_id) , ncol= length(dirs)))
piRNA_count <-  as.data.frame(matrix(data=0 , nrow=length(piRNA_id) , ncol= length(dirs)))
miRNA_count <-  as.data.frame(matrix(data=0 , nrow=length(miRNA_id) , ncol= length(dirs)))

sample_names <- as.data.frame(str_split(dirs,pattern="_",simplify=T)[,c(2,3,4)])
sample_names$names <- paste(sample_names$V1,sample_names$V2,sample_names$V3,sep="_")

names(tRNA_count) <- sample_names$names
names(piRNA_count) <- sample_names$names
names(miRNA_count) <- sample_names$names
rownames(tRNA_count) <- tRNA_id
rownames(piRNA_count) <- piRNA_id
rownames(miRNA_count) <- miRNA_id

for (i in 1:length(dirs)){
  tr <- tRNA[[i]]
  pir <- piRNA[[i]] 
  mir <- miRNA[[i]]
  index <- match(tr$ReferenceID,rownames(tRNA_count))
  tRNA_count[index,i] <- tr$uniqueReadCount
  
  index <- match(pir$ReferenceID,rownames(piRNA_count))
  piRNA_count[index,i] <- pir$uniqueReadCount
  
  index <- match(mir$ReferenceID,rownames(miRNA_count))
  miRNA_count[index,i] <- mir$uniqueReadCount
}

write.csv(tRNA_count,file=paste0(OutDir,"/",Prefix,"_tRNAS.csv"))
write.csv(piRNA_count,file=paste0(OutDir,"/",Prefix,"_piRNAS.csv"))
write.csv(miRNA_count,file=paste0(OutDir,"/",Prefix,"_miRNAS.csv"))

print("Done")




