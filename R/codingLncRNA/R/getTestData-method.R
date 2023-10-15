#' Get Test Data
#'
#' This method retrieves the test data stored in the package.
#'
#' @param object An object of class \code{LncRNAData}.
#' @return A data.frame containing the test data.
#' @importFrom data.table fread
#' @export
setGeneric("getTestData", function(object) standardGeneric("getTestData"))

#' @rdname getTestData
#' @export
setMethod("getTestData", "LncRNAData", function(object) {
  # Adjust to your data path
  test_data_path <- system.file("extdata", "test_data.csv", package = "codingLncRNA")
  
  # Load the test data
  test_data <- fread(test_data_path, na.strings = c("/", "NaN"))
  
  # Convert "0" to NA in the relevant columns after reading in the data
  test_data$RNA <- ifelse(test_data$RNA == "0", NA, test_data$RNA)
  test_data$Peptide <- ifelse(test_data$Peptide == "0", NA, test_data$Peptide)
  test_data$ORF_seq <- ifelse(test_data$ORF_seq == "0", NA, test_data$ORF_seq)
  
  # Return the adjusted test data
  test_data
})

