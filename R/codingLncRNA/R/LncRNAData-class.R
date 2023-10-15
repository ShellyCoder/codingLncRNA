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
  data_path <- system.file("extdata", "filtered_data.csv", package = "codingLncRNA")
  data <- fread(data_path, na.strings = c("/", "0", "NaN"))
  new("LncRNAData", data = data, rna = data.frame(), peptide = data.frame(), orf = data.frame())
}
