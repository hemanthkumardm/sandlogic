import re
import pandas as pd
import os

def parse_log_file(log_file_path):
    """Parses the log file to extract violation summary."""
    with open(log_file_path, 'r') as file:
        log_content = file.read()

    # Regular expression to match the Violation Summary table
    violation_summary_pattern = re.compile(
        r'Category\s*\| Error \| Warning \| Info \| Waived \| Total.*?\n(.*?)\n\n', re.DOTALL
    )

    # Find matches in the log content
    matches = violation_summary_pattern.findall(log_content)

    # Extract relevant data
    data = {}
    for match in matches:
        lines = match.strip().split('\n')
        for line in lines:
            if line.strip() and "----" not in line:  # Ignore empty and separator lines
                parts = re.split(r'\s{2,}', line.strip())  
                if len(parts) >= 2:  # Ensure we have at least Category and Total
                    category = parts[0]  # First column
                    total = parts[-1]    # Last column (Total count)
                    data[category] = total  # Store category with total count

    return data

def update_csv(csv_file_path, new_data):
    """Updates CSV by adding a new column for each new iteration."""
    if os.path.exists(csv_file_path):
        df = pd.read_csv(csv_file_path)
    else:
        df = pd.DataFrame(columns=['Category'])  # Initialize with Category column

    # Determine new iteration column name
    existing_iterations = [col for col in df.columns if col.startswith("Iteration")]
    new_iteration = f"Iteration_{len(existing_iterations) + 1}"

    # Convert new data to DataFrame
    new_df = pd.DataFrame(list(new_data.items()), columns=['Category', new_iteration])

    # Merge new data into existing DataFrame
    df = pd.merge(df, new_df, on="Category", how="outer").fillna(0)

    # Save updated DataFrame to CSV
    df.to_csv(csv_file_path, index=False)
    print(f"CSV updated successfully. Added: {new_iteration}")

if __name__ == "__main__":
    log_file_path = '/home/hemanth/sandlogic/sandlogic/testing/linting.log'
    csv_file_path = 'linting.csv'

    new_data = parse_log_file(log_file_path)
    if new_data:
        update_csv(csv_file_path, new_data)
    else:
        print("No new data found in the log file.")
