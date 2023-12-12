import pandas as pd
from joblib import load
from text_preprocessing import preprocess_text
from mertics_Diy import calculate_metrics
from simpletransformers.classification import ClassificationModel

def load_and_preprocess_data(file_path):
    data = pd.read_csv(file_path)
    processed_data = data.apply(
        lambda row: preprocess_text(text=row['Sentence'], label=row['label'], idx=row['Sentence_ID']),
        axis=1
    )
    return pd.DataFrame(
        processed_data.tolist(), 
        columns=["ID", 'Original_Text', 'Processed_Text', 'Label']
    )

def load_models_and_vectorizer(vectorizer_path, model_paths):
    vectorizer = load(vectorizer_path)
    models = {name: load(path) for name, path in model_paths.items()}
    return vectorizer, models

def predict_and_evaluate(test_data, vectorizer, models):
    X_test = vectorizer.transform(test_data['Processed_Text'].values)
    y_test = test_data['Label'].values.astype(int)

    results_df = pd.DataFrame({'actual_label': y_test})
    for name, model in models.items():
        predictions = model.predict_proba(X_test)[:, 1]
        results_df[f'{name}_predicted'] = predictions
        results_df[f'{name}_label'] = y_test

    for name in models.keys():
        auc, aupr, mcc = calculate_metrics(results_df, name)
        print(f"{name} Metrics: AUC = {auc:.3f}, AUPR = {aupr:.3f}, MCC = {mcc:.3f}")

# Main execution code
test_data_path = 'sentence-labeled.csv'
test_data = load_and_preprocess_data(test_data_path)

vectorizer_path = 'vectorizer.joblib'
model_paths = {
    'SVM': 'svm_model.joblib',
    'Logistic_Regression': 'logistic_model.joblib',
    'Random_Forest': 'random_forest_model.joblib'
}
vectorizer, models = load_models_and_vectorizer(vectorizer_path, model_paths)

predict_and_evaluate(test_data, vectorizer, models)


