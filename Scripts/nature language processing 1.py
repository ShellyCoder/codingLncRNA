import re
from nltk.tokenize import word_tokenize
from nltk.stem import PorterStemmer

# Initialize a stemmer from NLTK library.
stemmer = PorterStemmer()

def check_text_encoding(text, idx):
    # Try encoding the text in UTF-8, and report if there's an encoding error.
    try:
        text.encode('utf-8')
    except UnicodeEncodeError:
        print(f"Non UTF-8 characters found in entry index: {idx}")

    # Compile a regular expression pattern for detecting garbled text.
    garbled_text_pattern = re.compile(r'\?{4,}')
    # Check and report if the garbled text pattern is found in the text.
    if re.search(garbled_text_pattern, text):
        print(f"Potential garbled text found in entry index: {idx}")

def preprocess_text(text, label, idx):
    # Store the original text.
    orig_text = text
    # Check the text encoding and report any issues.
    check_text_encoding(text, idx)
    # Remove all non-word characters and digits, and then strip leading/trailing spaces.
    text = re.sub(r'[^\w\s]', '', text)
    text = re.sub(r'\d+', '', text)
    text = re.sub(r'\s+', ' ', text).strip()
    # Convert the text to lowercase.
    text = text.lower()
    # Tokenize the text into words.
    words = word_tokenize(text)
    # Stem each word in the text.
    words = [stemmer.stem(word) for word in words]
    # Join the stemmed words back into a string.
    text = ' '.join(words)
    # Return the processed text along with its original form and label.
    return idx, orig_text, text, label

if __name__ == "__main__":
    # Sample text for preprocessing
    sample_text = "The long non-coding RNA LINC00707 interacts with Smad proteins to regulate TGFβ signaling and cancer cell invasion."
    sample_label = 1  # Example label (can be adjusted based on actual use case)
    sample_idx = 0  # Example index for the text

    # Preprocessing the sample text
    preprocessed_result = preprocess_text(sample_text, sample_label, sample_idx)

    print("Original Text:", preprocessed_result[1])
    print("Processed Text:", preprocessed_result[2])
    print("Label:", preprocessed_result[3])
    print("Index:", preprocessed_result[0])
