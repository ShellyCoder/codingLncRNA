#' @import methods
#' @importFrom data.table fread
setClass(
  "LncRNAData",
  slots = list(
    data = "data.frame",
    rna = "data.frame",
    peptide = "data.frame",
    orf = "data.frame"
  )
)

#' @export
LncRNAData <- function() {
  data_path <- system.file("data", "filtered_data.csv", package = "codingLncRNA")
  
  # Read in the data without converting "0" to NA
  data <- fread(data_path, na.strings = c("/", "NaN"))
  
  # Convert "0" to NA in the relevant columns after reading in the data
  data$RNA <- ifelse(data$RNA == "0", NA, data$RNA)
  data$Peptide <- ifelse(data$Peptide == "0", NA, data$Peptide)
  data$ORF_seq <- ifelse(data$ORF_seq == "0", NA, data$ORF_seq)
  
  new("LncRNAData", data = data, rna = data.frame(), peptide = data.frame(), orf = data.frame())
}

