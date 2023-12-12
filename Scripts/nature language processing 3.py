import pandas as pd
from text_preprocessing import preprocess_text
from simpletransformers.classification import ClassificationModel
from mertics_Diy import calculate_metrics

def preprocess_data(file_path):
    data = pd.read_csv(file_path)
    processed_data = data.apply(
        lambda row: preprocess_text(text=row['Sentence'], label=row['label'], idx=row['Sentence_ID']),
        axis=1
    )
    return pd.DataFrame(
        processed_data.tolist(), 
        columns=["ID", 'Original_Text', 'Processed_Text', 'Label']
    )

def load_model(model_path, use_cuda=False):
    model = ClassificationModel("bert", model_path, use_cuda=use_cuda)
    return model

def predict_and_evaluate(model, test_data):
    predictions, raw_outputs = model.predict(test_data['Processed_Text'].values)
    auc, aupr, mcc = calculate_metrics(test_data, predictions)
    return auc, aupr, mcc

test_data_path = 'sentence-labeled.csv'
processed_df = preprocess_data(test_data_path)

model_path = "saved_model"
model = load_model(model_path)

auc, aupr, mcc = predict_and_evaluate(model, processed_df)

print(f"Model Metrics: AUC = {auc:.3f}, AUPR = {aupr:.3f}, MCC = {mcc:.3f}")





