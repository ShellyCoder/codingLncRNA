import pickle

def generate_prompt_v2(train_sentences, train_labels, test_sentences, num_examples=200):
    # Initialize an empty string for the prompt.
    prompt = ""

    # Add a task description to the prompt.
    prompt += ('You are a model skilled in identifying whether a given sentence describes '
               'a coding peptide derived from non-coding RNA (ncRNA). '
               'ncRNAs, such as lncRNA and circRNA, can translate peptides in non-classical translational events. '
               'Your task is to determine if the provided sentences describe a peptide coded by ncRNA, '
               'answering with a simple "Yes" or "No".\n\n')

    # Add examples from the training set.
    for i in range(min(num_examples, len(train_sentences))):
        sentence = train_sentences[i]
        label = train_labels[i]
        answer = "Yes" if label == 1 else "No"

        example = (f"Example {i + 1}:\n"
                   f"Sentence: \"{sentence}\"\n"
                   f"Question: Does this sentence describe a coding peptide from ncRNA?\n"
                   f"Answer: {answer}\n")

        prompt += example

    # Add sentences from the test set in a new format with numbering.
    for i in range(min(num_examples, len(test_sentences))):
        sentence = test_sentences[i]
        prompt += (f"Test Example {i + 1}:\n"  # Numbering added
                   f"Now, consider the following sentence:\n"
                   f"Sentence: \"{sentence}\"\n"
                   f"Question: Does this sentence describe a coding peptide from ncRNA?\n"
                   f"Answer: \n\n")

    return prompt

# Loading the training set.
with open("sentences_train.pkl", 'rb') as f:
    train_data = pickle.load(f)
train_sentences, train_labels = train_data

# Loading the test set.
with open("sentences_test.pkl", 'rb') as f:
    test_data = pickle.load(f)
test_sentences, _ = test_data  # Only taking sentences if the test set has no labels.

# Generating the prompt.
prompt = generate_prompt_v2(train_sentences, train_labels, test_sentences)

# Saving the generated prompt to a file.
with open("generated_prompt.txt", "w", encoding="utf-8") as f:
    f.write(prompt)

print("Prompt has been generated and saved.")






