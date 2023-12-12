from sklearn.metrics import roc_auc_score, average_precision_score, matthews_corrcoef
import pandas as pd

def calculate_metrics(df, model_name):
    actual = df[f'{model_name}_label']
    predicted_prob = df[f'{model_name}_predicted']

    # AUC
    auc = roc_auc_score(actual, predicted_prob)

    # AUPR
    aupr = average_precision_score(actual, predicted_prob)

    # To calculate MCC, we need to convert predicted probabilities to binary categories
    predicted_binary = (predicted_prob >= 0.5).astype(int)

    # MCC
    mcc = matthews_corrcoef(actual, predicted_binary)

    return auc, aupr, mcc

