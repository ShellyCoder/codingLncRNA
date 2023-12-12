import pandas as pd
# Load the expression data
expr_filepath = 'RNAseq_expr.txt'
expr_data = pd.read_csv(expr_filepath, sep="\t", index_col=0)

# Load the label data
label_filepath = 'Sample_label.txt'
label_data = pd.read_csv(label_filepath, sep="\t")

import itertools
import numpy as np

def create_pairwise_matrix_optimized(df):
    pairwise_columns = [f"{rna1}_vs_{rna2}" for rna1, rna2 in itertools.combinations(df.columns, 2)]
    pairwise_matrix = pd.DataFrame(0, index=df.index, columns=pairwise_columns)

    for rna1, rna2 in itertools.combinations(df.columns, 2):
        col_name = f"{rna1}_vs_{rna2}"
        difference = df[rna1] - df[rna2]
        pairwise_matrix[col_name] = np.where(np.abs(difference) <= 1, 0, np.sign(difference))

    return pairwise_matrix

if not all(expr_data.columns == label_data['sampleID']):
    expr_data = expr_data[label_data['sampleID']]

X = expr_data.transpose()
y = label_data['label']

from sklearn.model_selection import train_test_split

X_pairwise_opt = create_pairwise_matrix_optimized(X)
X_train_pw_opt, X_test_pw_opt, y_train_pw_opt, y_test_pw_opt = train_test_split(
    X_pairwise_opt, y, test_size=0.2, random_state=42, stratify=y
)

import xgboost
import shap
from sklearn.metrics import accuracy_score

model = xgboost.train({"learning_rate": 0.01}, xgboost.DMatrix(X_train_pw_opt, label=y_train_pw_opt), 100)
dtest = xgboost.DMatrix(X_test_pw_opt)
preds = model.predict(dtest)
preds_binary = [1 if pred > 0.5 else 0 for pred in preds]
print(f"Accuracy: {accuracy_score(y_test_pw_opt, preds_binary)}")

explainer = shap.Explainer(model)
shap_values = explainer(X_test_pw_opt)
shap.plots.bar(shap_values, show=False)
plt.savefig("./res_data/Squamous/shapValue_importance.pdf", dpi=600)

import pandas as pd
import xgboost
import shap
import numpy as np
import itertools
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import create_pairwise_matrix_optimized

def train_and_evaluate(expr_matrix, label_data, result_path):
    X_pairwise_opt = create_pairwise_matrix_optimized(expr_matrix.transpose())

    X_train_pw_opt, X_test_pw_opt, y_train_pw_opt, y_test_pw_opt = train_test_split(
        X_pairwise_opt, label_data['label'], test_size=0.2, random_state=42, stratify=label_data['label']
    )

    model = xgboost.train({"learning_rate": 0.01}, xgboost.DMatrix(X_train_pw_opt, label=y_train_pw_opt), 100)

    model.save_model(f"{result_path}/xgb_model.json")

    dtest = xgboost.DMatrix(X_test_pw_opt)
    preds = model.predict(dtest)

    # important genes
    explainer = shap.Explainer(model)
    shap_values = explainer(X_pairwise_opt)

    # Mean absolute SHAP values per feature
    mean_abs_shap_values = np.mean(np.abs(shap_values.values), axis=0)
    mean_shap_df = pd.DataFrame(mean_abs_shap_values, columns=['Mean |SHAP|'], index=X_pairwise_opt.columns)
    sorted_mean_shap = mean_shap_df.sort_values(by='Mean |SHAP|', ascending=False)

    # save
    sorted_mean_shap.to_csv(f"{result_path}/feature_importance.csv")

    # Create a DataFrame with test sample IDs, predictions and true labels
    results_df = pd.DataFrame({
        'SampleID': X_test_pw_opt.index,
        'tumor_type': label_data.loc[X_test_pw_opt.index, 'tumor_type'],
        'Prediction': preds, 
        'True_Label': y_test_pw_opt
    })

    # Check if the order of the sample IDs matches between the predictions and true labels
    if all(results_df['SampleID'] == y_test_pw_opt.index):
        results_df.to_csv(f"{result_path}/predictions.csv", index=False)
    else:
        print("Error: The order of sample IDs does not match between predictions and true labels.")




