
# codLncScape provides a self-enriching framework for systematic collection and exploration of coding lncRNAs

`codingLncRNA` is a utility package available both in R and Python, designed to facilitate easy management and retrieval of lncRNAs which code peptides, including RNA sequences, peptide sequences, and ORF sequences. In addition, this `Scripts` directory is an integral part of the codLncScape dedicated to the bioinformatics analysis of coding lncRNAs. 

- [R Package Usage](#r-package-usage)
- [Python Package Usage](#python-package-usage)

## R Package Usage

### Installation

To install the `codingLncRNA` R package, make sure you have the `devtools` package installed and loaded in your R session. You can install it using:

```r
install.packages("devtools")
```

Then, install `codingLncRNA` from GitHub with:

```r
devtools::install_github("ShellyCoder/codingLncRNA/R/codingLncRNA")
```

### Usage

1. **Creating LncRNAData Object**

First, we will utilize the `LncRNAData` function to create an object of `LncRNAData`, which incorporates the sample data included in the package.

```r
library(codingLncRNA)
lncRNAData <- LncRNAData()
```

2. **Retrieving RNA, Peptide, and ORF Sequences**

The `codingLncRNA` package offers several methods that allow the user to access and retrieve RNA, peptide, and ORF sequences:

```r
lncRNAData <- getRNA(lncRNAData)
lncRNAData <- getPeptide(lncRNAData)
lncRNAData <- getORF(lncRNAData)
```

Each method retrieves the corresponding sequences and stores them as a dataframe in the respective slot of the `LncRNAData` object. For instance, to view the retrieved RNA sequences, you can utilize the following command:

```r
View(lncRNAData@data)
View(lncRNAData@rna)
View(lncRNAData@peptide)
View(lncRNAData@orf)
```

<!-- #### Obtaining Independent Dataset
This package also provides Independent dataset collecting coding-peptide lncRNAs confirmed in the July-October 2023 published literature.
To obtain the Independent data that is incorporated in the `codingLncRNA` package, you can use the `getTestData` function:

```r
testData <- getTestData(lncRNAData)
```
This will return a dataframe containing the Independent data.
-->


## Python Package Usage

### Installation

To install the `codingLncRNA` Python package, you can use `pip` to install directly from GitHub:

```bash
pip install git+https://github.com/ShellyCoder/codingLncRNA.git#subdirectory=python
```

### Usage

1. **Loading Data:**

```python
from codingLncRNA import LncRNAData, load_data

# Load data
lncRNAData = LncRNAData()
```

2. **Retrieving Sequences:**

```python
# Get RNA sequences
rna_sequences = lncRNAData.getRNA()

# Get Peptide sequences
peptide_sequences = lncRNAData.getPeptide()

# Get ORF sequences
orf_sequences = lncRNAData.getORF()
```

<!-- #### 3. **Obtaining Independent Dataset**
This package also provides Independent dataset collecting coding-peptide lncRNAs confirmed in the July-October 2023 published literature.

```python
testData <- lncrna.getTestData()
```
This will return a dataframe containing the Independent data.
-->

## Additional Information

This package is still under development. For any issues or suggestions, please [submit an issue](https://github.com/ShellyCoder/codingLncRNA/issues) on the GitHub repository.
