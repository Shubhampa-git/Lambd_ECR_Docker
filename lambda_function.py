import pandas as pd

def handler(event, context):
    # Replace 'your_file.csv' with the path to your CSV file
    csv_file_path = 'test.csv'

    # Read the CSV file into a DataFrame
    df = pd.read_csv(csv_file_path)

    # # Print the DataFrame
    # df.to_excel("test.xlsx")
    print(df)
