# Clear the workspace
rm(list = ls())
# Set default behavior for string handling
options(stringsAsFactors = F)

# Set the working directory to a specified path
setwd("/Users/luca/myWorkSpace/codingLnc/code/")
# List all files in a specific directory with a '.gz' extension
file_names <- list.files(path = "./Sperm/GSE106487_RAW/", pattern = "\\.gz$")

# Read each file and create a list of data frames
spermData_list <- lapply(file_names, function(f) {
  read.table(gzfile(paste0("./Sperm/GSE106487_RAW/", f)), header=TRUE, sep="\t", stringsAsFactors=FALSE)
})

# Process each data frame: set row names as gene names and remove the gene column
spermData_list_new <- lapply(spermData_list, function(df_tmp){
  rownames(df_tmp) <- df_tmp$Gene
  df_tmp$Gene <- NULL
  return(df_tmp)
})

# Display the first 4 rows and columns of the first data frame for inspection
spermData_list_new[[1]][1:4,1:4]

# Combine all data frames in the list into a single data frame
spermData_df <- do.call('cbind', spermData_list_new)
# Display the first 4 rows and 6 columns of the combined data frame
spermData_df[1:4,1:6]

# Read another data set, specifying tab as the delimiter
codingLnc_df <- read.table("/Users/luca/Desktop/03_codingLncData_20230917_rawData.txt", sep = '\t', header = T)
# Display dimensions of the data frame
dim(codingLnc_df)
# Display the number of unique values in a specific column
length(unique(codingLnc_df$Name..standard.))

# Create a set of unique names from a specific column
codingLncSet <- unique(codingLnc_df$Name..standard.)

# Identify common elements between two sets
codingLncSet_sperm <- intersect(codingLncSet, rownames(spermData_df))

# Read metadata for cell types
sperm_cellType <- read.table("./Sperm/GSE106487_meta/cell_type.txt", sep = '\t', header = T)
# Display the first few rows of the data frame
head(sperm_cellType)

# Display frequency of each class in the data frame
table(sperm_cellType$class)

# Filter rows based on a condition and display the frequency of matching cell names
target_barcode <- dplyr::filter(sperm_cellType, class %in% c("SSC.subpopulation1", "SSC.subpopulation2", "Diff.ing.SPG", "Diff.ed.SPG"))
table(target_barcode$cell %in% colnames(spermData_df))
# Identify elements present in one set but not the other
setdiff(target_barcode$cell, colnames(spermData_df))

# Find column names starting with 'X' and count them
grepl(pattern = "^X", x = colnames(spermData_df)) %>% table()
# Remove a specific pattern from the column names
colnames(spermData_df) <- stringr::str_remove(colnames(spermData_df), "^X")

# Recount the frequency of matching cell names after renaming columns
table(target_barcode$cell %in% colnames(spermData_df))


# Subset the data frame to include only columns corresponding to target barcodes
spermData_df_3_Stages <- spermData_df[, target_barcode$cell]
# Count the number of NA values and negative values in the subset
table(is.na(spermData_df_3_Stages))
table(spermData_df_3_Stages<0)

# Display dimensions of the subset
dim(spermData_df_3_Stages)
# Rename columns of the subset for clarity
colnames(spermData_df_3_Stages) <- paste(1:nrow(target_barcode), target_barcode$class, sep = "_")

# Display the range of sums of positive values across columns and rows
range(colSums(spermData_df_3_Stages>0))
range(rowSums(spermData_df_3_Stages>0))

# Display frequency of rows with a minimum number of positive values
table(rowSums(spermData_df_3_Stages>0)>=3)

# Display current dimensions of the subset
dim(spermData_df_3_Stages)
# Filter the subset based on the sum of positive values in rows and columns
spermData_df_3_Stages <- spermData_df_3_Stages[ rowSums(spermData_df_3_Stages>0)>=3 , colSums(spermData_df_3_Stages>0)>=2000 ]
# Display new dimensions after filtering
dim(spermData_df_3_Stages)

# Further subset the data to include only lncRNAs
spermData_df_3_Stages_lncRNA <- spermData_df_3_Stages[intersect(codingLncSet_sperm, rownames(spermData_df_3_Stages)),]
# Display dimensions and count NA and negative values in the new subset
dim(spermData_df_3_Stages_lncRNA)
table(is.na(spermData_df_3_Stages_lncRNA))
table(spermData_df_3_Stages_lncRNA<0)

# Save the final subsets to RDS files
saveRDS(spermData_df_3_Stages, file = "spermData_df_3_Stages.rds")
saveRDS(spermData_df_3_Stages_lncRNA, file = "spermData_df_3_Stages_lncRNA.rds")
