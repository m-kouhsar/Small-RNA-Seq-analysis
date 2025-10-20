message("Loading requiered libraries...")
suppressMessages(library(dplyr))
library(purrr)
library(data.table)
library(stringr)

################################################################################
merge_dfs <- function(dfs, by, keep = NULL) {
  # dfs: named list of dataframes
  # by: vector of key column names
  # keep: character vector of columns (besides keys) to keep from all dfs
  
  stopifnot(is.list(dfs), !is.null(names(dfs)))
  
  dfs_prepared <- Map(function(df, nm) {
    # Select only relevant columns
    if (is.null(keep)) {
      df_sel <- df
    } else {
      cols_to_keep <- intersect(c(by, keep), names(df))
      df_sel <- df[, cols_to_keep, drop = FALSE]
    }
    
    # Add prefix to non-key columns
    nonkey_cols <- setdiff(names(df_sel), by)
    names(df_sel)[names(df_sel) %in% nonkey_cols] <- paste0(nm, "_", nonkey_cols)
    
    df_sel
  }, dfs, names(dfs))
  
  # Merge all data frames with full join
  merged_df <- Reduce(function(x, y) full_join(x, y, by = by), dfs_prepared)
  merged_df <- merged_df %>%
    mutate(across(where(is.numeric), ~replace(.,is.na(.), 0)))
  merged_df
}

################################################################################
arguments <- commandArgs(T)

mintmap.results.dir = trimws(arguments[1])
OutPrefix = trimws(arguments[2])

message("Checking the mintmap results directory...")

amb.files = data.frame(amb_file = list.files(path = mintmap.results.dir , pattern = "ambiguous-tRFs.expression.txt",full.names = F , recursive = T))
message(nrow(amb.files) , " ambiguous tRFs expression files detected.")
amb.files$sample = str_remove(amb.files$amb_file , pattern = "-MINTmap_.*-ambiguous-tRFs.expression.txt")

exc.files = data.frame(exc_file = list.files(path = mintmap.results.dir , pattern = "exclusive-tRFs.expression.txt",full.names = F , recursive = T))
message(nrow(exc.files) , " exclusive tRFs expression files detected.")
exc.files$sample = str_remove(exc.files$exc_file , pattern = "-MINTmap_.*-exclusive-tRFs.expression.txt")

amb.meta.files = data.frame(amb_meta_file = list.files(path = mintmap.results.dir , pattern = "ambiguous-tRFs.countsmeta.txt",full.names = F , recursive = T))
message(nrow(amb.meta.files) , " ambigouos meta files detected.")
amb.meta.files$sample = str_remove(amb.meta.files$amb_meta_file , pattern = "-MINTmap_.*-ambiguous-tRFs.countsmeta.txt")

exc.meta.files = data.frame(exc_meta_file = list.files(path = mintmap.results.dir , pattern = "exclusive-tRFs.countsmeta.txt",full.names = F , recursive = T))
message(nrow(exc.meta.files) , " exclusive meta files detected.")
exc.meta.files$sample = str_remove(exc.meta.files$exc_meta_file , pattern = "-MINTmap_.*-exclusive-tRFs.countsmeta.txt")

all_files <-   Reduce(function(x,y){merge(x, y , by = "sample" , all = TRUE)},list(amb.files , exc.files , amb.meta.files , exc.meta.files) )

amb.all <- amb.meta.all <- exc.all <- exc.meta.all <- setNames(
  vector("list", nrow(all_files)),
  all_files$sample
)


message("Reading the mintmap result files...")
for (i in 1:nrow(all_files)) {
  #message("Read ",i,"/",nrow(all_files))
  if(!is.na(all_files$amb_file[i])){
    amb.all[[all_files$sample[i]]] = fread(paste0(mintmap.results.dir , "/",all_files$amb_file[i]) , data.table = F , stringsAsFactors = F)
  }
  
  if(!is.na(all_files$exc_file[i])){
    exc.all[[all_files$sample[i]]] = fread(paste0(mintmap.results.dir , "/",all_files$exc_file[i]) , data.table = F , stringsAsFactors = F)
  }
  
  if(!is.na(all_files$amb_meta_file[i])){
    amb.meta.all[[all_files$sample[i]]] = fread(paste0(mintmap.results.dir , "/",all_files$amb_meta_file[i]) , data.table = F , stringsAsFactors = F)
  }
  
  if(!is.na(all_files$exc_meta_file[i])){
    exc.meta.all[[all_files$sample[i]]] = fread(paste0(mintmap.results.dir , "/",all_files$exc_meta_file[i]) , data.table = F , stringsAsFactors = F)
  }
  
}

message("merging results...")
amb.all <- amb.all[!is.na(amb.all)]
exc.all <- exc.all[!is.na(exc.all)]
amb.meta.all <- amb.meta.all[!is.na(amb.meta.all)]
exc.meta.all <- exc.meta.all[!is.na(exc.meta.all)]

amb.all <- Filter(function(df) nrow(df) > 0, amb.all)
exc.all <- Filter(function(df) nrow(df) > 0, exc.all)
amb.meta.all <- Filter(function(df) nrow(df) > 0, amb.meta.all)
exc.meta.all <- Filter(function(df) nrow(df) > 0, exc.meta.all)

amb_count_unnormalized = merge_dfs(dfs = amb.all , by = names(amb.all[[1]])[1:3] , keep = names(amb.all[[1]])[4])
exc_count_unnormalized = merge_dfs(dfs = exc.all , by = names(exc.all[[1]])[1:3] , keep = names(exc.all[[1]])[4])
amb_meta = do.call(rbind.data.frame , amb.meta.all)
exc_meta = do.call(rbind.data.frame , exc.meta.all)

message("Writing merged counts...")
write.csv(all_files , file = paste0(OutPrefix , ".mintmap.results.csv") , row.names = F)
write.table(amb_count_unnormalized , file = paste0(OutPrefix , ".ambiguous.tRFs.count.txt") , col.names = T , row.names = F , quote = F , sep = "\t")
write.table(exc_count_unnormalized , file = paste0(OutPrefix , ".exclusive.tRFs.count.txt") , col.names = T , row.names = F , quote = F , sep = "\t")
write.csv(amb_meta , file = paste0(OutPrefix , ".ambiguous.tRFs.metadata.csv"))
write.csv(exc_meta , file = paste0(OutPrefix , ".exclusive.tRFs.metadata.csv"))

message("All done!")


