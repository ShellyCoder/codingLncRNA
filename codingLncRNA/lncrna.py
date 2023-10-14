import pandas as pd
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
        sequences = self.data.loc[self.data[sequence_column] != "/", sequence_column].copy()
        result_df = pd.DataFrame({
            'sequence': sequences,
            'label': label
        })
        print(f"Removed rows with '/', returning {len(result_df)} sequences.")
        return result_df
