# ==============================================================================
# tRNA Count Matrix Collapsing Pipeline
# Description: Identifies tRNAs with identical count profiles across all samples,
#              sums their counts, merges their IDs using "|", and exports the result.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Configuration & Parameters
# ------------------------------------------------------------------------------
args <- commandArgs(T)
input_file  <- args[1]          # Path to input file (TSV)
output_file <- args[2]          # Path for output collapsed matrix

# ------------------------------------------------------------------------------
# 2. Read and Validate Input Data
# ------------------------------------------------------------------------------
cat("[INFO] Loading count matrix from:", input_file, "\n")

raw_data <- read.table(
  file = input_file,
  header = TRUE,
  row.names = 1,
  sep = "\t",
  check.names = FALSE,
  stringsAsFactors = FALSE
)

# Convert to a standard numeric matrix
count_matrix <- as.matrix(raw_data)

if (!is.numeric(count_matrix)) {
  stop("[ERROR] Matrix contains non-numeric values. Please check your input.")
}

total_original_tRNAs <- nrow(count_matrix)
total_samples        <- ncol(count_matrix)

cat("[INFO] Input dimensions:", total_original_tRNAs, "tRNAs across", total_samples, "samples.\n")

# ------------------------------------------------------------------------------
# 3. Identify Identical Expression Signatures
# ------------------------------------------------------------------------------
cat("[INFO] Identifying rows with identical profiles...\n")

# Create a unique row signature string
row_signatures <- apply(count_matrix, 1, paste, collapse = "_")

# Group row indices by identical signatures
grouped_indices <- split(seq_len(total_original_tRNAs), row_signatures)

# ------------------------------------------------------------------------------
# 4. Collapse Identical Rows (Sum Counts & Merge IDs)
# ------------------------------------------------------------------------------
cat("[INFO] Collapsing counts and merging tRNA IDs...\n")

# Process each group: concatenate IDs and calculate summed counts
# Pre-allocate empty list
collapsed_list <- vector("list", length(grouped_indices))

# Iterate through grouped indices
for (i in seq_along(grouped_indices)) {
  idx <- grouped_indices[[i]]
  
  # Concatenate all tRNA IDs in the group with "|"
  merged_id <- paste(rownames(count_matrix)[idx], collapse = "|")
  
  # For identical rows, the sum is simply (row_values * number_of_duplicates)
  group_size <- length(idx)
  if (group_size == 1) {
    summed_counts <- count_matrix[idx, ]
  } else {
    summed_counts <- count_matrix[idx[1], ] * group_size
  }
  
  collapsed_list[[i]] <- list(id = merged_id, counts = summed_counts)
}

# Reconstruct collapsed matrix
collapsed_matrix <- do.call(rbind, lapply(collapsed_list, function(x) x$counts))
rownames(collapsed_matrix) <- vapply(collapsed_list, function(x) x$id, character(1))
colnames(collapsed_matrix) <- colnames(count_matrix)

# ------------------------------------------------------------------------------
# 5. Summary Statistics
# ------------------------------------------------------------------------------
total_collapsed_features <- nrow(collapsed_matrix)
duplicated_groups_count  <- sum(lengths(grouped_indices) > 1)
total_tRNAs_in_groups    <- sum(lengths(grouped_indices)[lengths(grouped_indices) > 1])

cat("\n==================================================\n")
cat("                PROCESSING SUMMARY                \n")
cat("==================================================\n")
cat("Total original tRNAs        :", total_original_tRNAs, "\n")
cat("Total collapsed features    :", total_collapsed_features, "\n")
cat("Identical profile groups    :", duplicated_groups_count, "\n")
cat("tRNAs merged into groups    :", total_tRNAs_in_groups, "\n")
cat("Dimensionality reduction    :", total_original_tRNAs - total_collapsed_features, "rows removed\n")
cat("==================================================\n\n")

# ------------------------------------------------------------------------------
# 6. Export Results
# ------------------------------------------------------------------------------
cat("[INFO] Saving collapsed matrix to:", output_file, "\n")

write.table(
  x = collapsed_matrix,
  file = output_file,
  sep = "\t",
  col.names = NA,
  row.names = TRUE,
  quote = FALSE
)

cat("[SUCCESS] Pipeline completed successfully.\n")