import pandas as pd
import os

class LncRNAData:
    def __init__(self):
        data_path = os.path.join(os.path.dirname(__file__), "data", "filtered_data.csv")
        self.data = pd.read_csv(data_path)

    def get_sequences(self, sequence_type):
        sequence_column = {
            'rna': 'RNA',
            'peptide': 'Peptide',
            'orf': 'ORF_seq'
        }.get(sequence_type.lower())
        
        if sequence_column is None:
            raise ValueError("Invalid sequence_type. Expected one of: 'rna', 'peptide', 'orf'")
        
        sequences = self.data.loc[self.data[sequence_column] != "/", sequence_column]
        print(f"Removed rows with '/', returning {len(sequences)} sequences.")
        return sequences

def load_data():
    return LncRNAData().data
