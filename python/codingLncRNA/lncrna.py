import pandas as pd
import numpy as np
import os

class LncRNAData:
    def __init__(self):
        data_path = os.path.join(os.path.dirname(__file__), "data", "filtered_data.csv")
        self.data = pd.read_csv(data_path)

    def getRNA(self, label="coding peptide LncRNA"):
        return self._get_sequences('RNA', label)
    
    def getPeptide(self, label="coding peptide LncRNA"):
        return self._get_sequences('Peptide', label)

    def getORF(self, label="coding peptide LncRNA"):
        return self._get_sequences('ORF_seq', label)
    
    def _get_sequences(self, sequence_column, label):
        sequences = self.data.loc[~self.data[sequence_column].isin(["/", "0", np.nan]), sequence_column].copy()
        result_df = pd.DataFrame({
            'sequence': sequences,
            'label': label
        })
        print(f"Removed un-annotated {sequence_column} with '/' or '0', returning {len(result_df)} sequences.")
        return result_df
    
    def getTestData(self):
        # Specify the path to your test data
        test_data_path = os.path.join(os.path.dirname(__file__), "data", "test_data.csv")
        
        # Load and return the test data
        return pd.read_csv(test_data_path)

def load_data():
    return LncRNAData().data    
