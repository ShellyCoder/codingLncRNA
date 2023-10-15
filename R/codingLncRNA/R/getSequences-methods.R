#' @import methods
#' @importFrom data.table fread

setGeneric("getSequences", function(object, sequence_column, label = "coding peptide LncRNA") standardGeneric("getSequences"))

#' @rdname getSequences
#' @export
setMethod(
  "getSequences", "LncRNAData",
  function(object, sequence_column, label = "coding peptide LncRNA") {
    sequences <- object@data[!is.na(object@data[[sequence_column]]), sequence_column, drop = FALSE]
    message("Removed un-annotated ", sequence_column, " with '/' or '0', returning ", nrow(sequences), " sequences.")
    data.frame(sequence = sequences, label = label, stringsAsFactors = FALSE)
  }
)

#' @export
setGeneric("getRNA", function(object, label = "coding peptide LncRNA") standardGeneric("getRNA"))

#' @rdname getRNA
#' @export
setMethod(
  "getRNA", "LncRNAData",
  function(object, label = "coding peptide LncRNA") {
    object@rna <- getSequences(object, "RNA", label)
    object
  }
)

#' @export
setGeneric("getPeptide", function(object, label = "coding peptide LncRNA") standardGeneric("getPeptide"))

#' @rdname getPeptide
#' @export
setMethod(
  "getPeptide", "LncRNAData",
  function(object, label = "coding peptide LncRNA") {
    object@peptide <- getSequences(object, "Peptide", label)
    object
  }
)

#' @export
setGeneric("getORF", function(object, label = "coding peptide LncRNA") standardGeneric("getORF"))

#' @rdname getORF
#' @export
setMethod(
  "getORF", "LncRNAData",
  function(object, label = "coding peptide LncRNA") {
    object@orf <- getSequences(object, "ORF_seq", label)
    object
  }
)
