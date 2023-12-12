# Clear all objects from memory
rm(list = ls())
# Set default option for handling strings as not factors
options(stringsAsFactors = F)

# Set the working directory
setwd("/Users/luca/myWorkSpace/codingLnc/code/TCGA/pancancer_xena/")

# Read tumor TPM data and associated clinical data
myLncDF_TPM_tumor <- readRDS("../res_data/myLncDF_TPM_tumor.rds")
myLncDF_TPM_tumor_clinic <- readRDS("../res_data/myLncDF_TPM_tumor_clinic.rds")

# Preview the first few rows and columns of the tumor TPM data
myLncDF_TPM_tumor[1:4,1:4]
# Check for negative values in the data
table(myLncDF_TPM_tumor<0)

# Load necessary libraries for analysis
library(Seurat)
library(Matrix)
# Create a Seurat object from the TPM data
tcga_Obj <- CreateSeuratObject(counts = t(myLncDF_TPM_tumor), project = "tcga", 
                           min.cells = 0, min.features = 0)

# Log transform the already normalized data
tcga_Obj@assays$RNA@data <- as(as.matrix(log(t(myLncDF_TPM_tumor) + 1)), "sparseMatrix")
# Scale the data and run principal component analysis
tcga_Obj <- ScaleData(object = tcga_Obj, features = rownames(tcga_Obj))
tcga_Obj <- RunPCA(object = tcga_Obj, features = rownames(tcga_Obj), verbose = F)
# Plot elbow plot to determine number of PCs
ElbowPlot(tcga_Obj)

# Add cancer metadata
head(tcga_Obj@meta.data)
# Ensure sample order consistency
identical(rownames(tcga_Obj@meta.data), rownames(myLncDF_TPM_tumor_clinic)) 
# Add tumor type and gender information
tcga_Obj@meta.data$tumor_type <- myLncDF_TPM_tumor_clinic[, "project"]
tcga_Obj@meta.data$gender <- myLncDF_TPM_tumor_clinic[, "gender"]

# Handle missing values in immune subtype
myLncDF_TPM_tumor_clinic$Subtype_Immune_Model_Based[is.na(myLncDF_TPM_tumor_clinic$Subtype_Immune_Model_Based)] <- "unknown"
# Add immune subtype information
tcga_Obj@meta.data$Subtype_Immune <- myLncDF_TPM_tumor_clinic[, "Subtype_Immune_Model_Based"]

# Read additional cancer type information
cancer_diyType <- read.table("../cancer_type.txt", sep = '\t', header = T, comment.char = "")
# Check the consistency of cancer types
table(cancer_diyType$Cancer %in% unique(tcga_Obj@meta.data$tumor_type))

# Merge additional cancer type information
tmp_df <- left_join(x = tcga_Obj@meta.data, y = cancer_diyType, by = c("tumor_type" = "Cancer"))
tcga_Obj@meta.data$Cell_subType <- tmp_df$Cell_subType
tcga_Obj@meta.data$Cell_location <- tmp_df$Cell_location

# Check for missing values in metadata
table(is.na(tcga_Obj@meta.data))

# Pre-set color schemes for visualization
# Load pre-saved Seurat object and clustering data
tcga_Obj <- readRDS("../res_data/tcga_Obj.rds")
deg_cluster <- readRDS("../res_data/deg_cluster.rds")

# Run t-SNE for dimensionality reduction
tcga_Obj <- RunTSNE(object = tcga_Obj, dims = 1:20, perplexity = 30)
# Plot t-SNE with tumor types
# (Plotting code for t-SNE)

# Perform clustering analysis
tcga_Obj <- FindNeighbors(object = tcga_Obj, reduction = "pca", dims = 1:20)
tcga_Obj <- FindClusters(object = tcga_Obj, resolution = 0.5) 

# Identify cluster-specific lncRNAs
# Set default group for differential expression analysis
Idents(tcga_Obj) <- 'RNA_snn_res.0.5'
# Perform differential expression analysis
deg_cluster <- FindAllMarkers(tcga_Obj, grouping.var = "RNA_snn_res.0.5",
                              only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.25)

# Extract PMIDs for differentially expressed genes
codingLnc_df <- read.table("/Users/luca/Desktop/03_codingLncData_20230917_rawData.txt", sep = '\t', header = T)
codingLnc_df[codingLnc_df$Name..standard. %in% unique(deg_cluster$gene), "PMID"] %>% unique()

# Select top differentially expressed gene per cluster
deg_cluster_top1 <- deg_cluster %>% group_by(cluster) %>% top_n(n = 1, wt = avg_log2FC)

# Visualization of cluster marker genes using FeaturePlot
# (FeaturePlot visualization code)

# Optional violin plot for cluster marker genes
# (Optional code for violin plot visualization)

# Save Seurat object and clustering results
saveRDS(tcga_Obj, file = "../res_data/tcga_Obj.rds")
saveRDS(deg_cluster, file = "../res_data/deg_cluster.rds")

# Create a data frame with tumor types and counts
tumor_data <- data.frame(
  Tumor_Type = names(table(tcga_Obj@meta.data$tumor_type)),
  Count = as.numeric(table(tcga_Obj@meta.data$tumor_type))
)

# Save the tumor data to a text file
write.table(tumor_data, file = "../../../data/supplementary/tumor_counts.txt", 
            sep = "\t", row.names = FALSE, quote = F)
