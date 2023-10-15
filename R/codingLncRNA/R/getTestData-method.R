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

  # Load and return the test data
  fread(test_data_path)
})
