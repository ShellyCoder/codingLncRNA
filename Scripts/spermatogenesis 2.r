##############
# Analyze lncRNAs related to development based on obtained pseudotime information
#####################

# Clear all objects from memory
rm(list = ls())
# Set default option for handling strings as not factors
options(stringsAsFactors = F)

# Set the working directory
setwd("/Users/luca/myWorkSpace/codingLnc/code/")

# Read the sorted pseudotime data
pseudotime_sorted <- readRDS("./Sperm/pseudotime_from_allRNA_infer.rds")
# Read the sperm object for lncRNA analysis
sperm_Obj <- readRDS("sperm_Obj_lncRNA.rds")

# Convert the RNA assay data to a matrix and then to a data frame
expr_matrix <- as.matrix(sperm_Obj@assays$RNA@data) %>% as.data.frame()

# Sort the expression matrix according to pseudotime
sorted_expr <- as.matrix(expr_matrix)[, names(pseudotime_sorted)]
# Check for missing values in the sorted expression matrix
table(is.na(sorted_expr))

# Construct column annotation information
# Check for missing values in the cellType metadata
sperm_Obj@meta.data[names(pseudotime_sorted), "cellType"] %>% is.na() %>% table()

# Create a data frame for column annotations with pseudotime and cell type
annotation_col = data.frame(
  times = as.numeric(pseudotime_sorted),
  cell_type = sperm_Obj@meta.data[names(pseudotime_sorted), "cellType"]
)
rownames(annotation_col) = names(pseudotime_sorted)
# Display the first few rows of column annotations
head(annotation_col)

# Check if column names of the sorted expression matrix match the row names of the annotation data
identical(colnames(sorted_expr), rownames(annotation_col))

# Identify lncRNAs related to time
# Calculate Spearman's correlation between each lncRNA and pseudotime
correlation_results <- sapply(1:nrow(sorted_expr), function(i) {
  tmp <- cor.test(sorted_expr[i,], pseudotime_sorted, method="spearman")
  c(r = tmp$estimate, p = tmp$p.value)
})
# Transpose and label the correlation results
correlation_results <- t(correlation_results)
colnames(correlation_results) <- c("r", "p")
rownames(correlation_results) <- rownames(sorted_expr)

# Filter lncRNAs with significant and strong correlation with pseudotime
realted_lncRNA <- filter(as.data.frame(correlation_results), abs(r)>0.2 & p<0.05)

# Scale the expression of related lncRNAs and truncate extreme values
scale_expr_scaled <- t(scale(t(sorted_expr[rownames(realted_lncRNA),])))

scale_expr_scaled[scale_expr_scaled>2] = 2
scale_expr_scaled[scale_expr_scaled<(-2)] = -2
 
# Create a heatmap of scaled expressions
p1 <- pheatmap::pheatmap(mat = scale_expr_scaled, scale = "none",
                   cluster_cols = F, cluster_rows = T,
                   show_colnames = F, show_rownames = T,
                   color = colorRampPalette(colors = c("blue", "#D6E8FF","white", "#FFD6D6","red"))(100),
                   annotation_col = annotation_col)

# Create a plot for visualizing pseudotime
df <- data.frame(pseudotime = as.numeric(pseudotime_sorted),
                 x_tmp = 1:length(pseudotime_sorted))
p2 <- ggplot(df, aes(x = x_tmp, y = 1, fill = pseudotime)) +
  geom_tile(aes(height = 1, width = 1)) +
  scale_fill_gradientn(colors = c("#bbdefb", "#64b5f6", "#1e88e5", "#0d47a1")) +
  labs(fill = "Pseudotime", x = "x_tmp", y = "", title = "Color-coded Pseudotime") +
  theme_minimal() + theme(axis.title.y=element_blank(), axis.text.y=element_blank(), axis.ticks.y=element_blank())
p1
p2

# Extract label order
# Cluster the heatmap and extract label order
cut <- cutree(p1$tree_row,k=2)  
dat_cut <- cbind("gene" = rownames(scale_expr_scaled),"group" = cut) %>% as.data.frame()

# Filter genes belonging to different clusters
gene_cluster1 <- dplyr::filter(dat_cut, group=="1")[,1]
gene_cluster2 <- dplyr::filter(dat_cut, group=="2")[,1]

# Save the gene clusters
saveRDS(list(cluster1_gene = gene_cluster1,
             cluster2_gene = gene_cluster2), file = "Sperm_specific_lncRNA.rds")

# Additional visualization using ggtree
library(ggtree)
library(ape)
library(tidytree)
# Convert hcluster object to phylo object for visualization
tr <- ape::as.phylo(p1$tree_row) 
tidytree::as_tibble(tr)

# Prepare data for ggtree visualization
my_top_data <- realted_lncRNA
my_top_data$size <- -log10(my_top_data$p)
my_top_data$myShape <- "a"

# Scale the size of points based on p-value
my_top_data$size[ my_top_data$size>=5 ] = 3
my_top_data$size[ my_top_data$size>=4 & my_top_data$size<5 ] = 2
my_top_data$size[ my_top_data$size>=3 & my_top_data$size<4] = 1

# Align data with heatmap labels
my_top_data <- my_top_data[p1$tree_row$labels, ]
my_top_data$Newick_label <- rownames(my_top_data)
table(is.na(my_top_data))

# Create a circular tree plot with heatmap
p1 <- ggtree(tr, layout="circular")
gheatmap(p1, scale_expr_scaled, colnames = T, colnames_offset_y = 0.6, color= NULL) + 
  scale_fill_gradientn(colors = colorRampPalette(c("blue", "#A4CBFC", "white", "#FDAFAF", "red"))(100))

# Add labels to the plot
p1 + geom_tiplab2()+
  xlim(0,20)















