import csv
import re
import os

def parse_report(report_text):
    data = {}
    summary_pattern = re.compile(r'^\s*(.+?)\s+(\d+)\s*$', re.MULTILINE)
    matches = summary_pattern.findall(report_text)
    for name, value in matches:
        data[name.strip()] = int(value)
    return data

import re

def extract_lef_cells(report_text):
    # Regular expression to capture cell names after "lib_cell:"
    lef_cells_pattern = re.compile(r'lib_cell:[^/]+/([^/]+)')
    
    # Find all matches in the report
    lef_cells = lef_cells_pattern.findall(report_text)
    
    # Return the list of unique LEF cell names
    return lef_cells

def main():
    report_file_path = '/home/hemanth/sandlogic/sandlogic/testing/genus1.log'  
    csv_file = 'output.csv'
    
    with open(report_file_path, 'r') as file:
        report_text = file.read()
    
    # Extract the LEF cells with no corresponding libcell
    lef_cells = extract_lef_cells(report_text)
    for cell in lef_cells:
        print(cell)
    
    # Existing logic to process report and update CSV
    new_data = parse_report(report_text)
    iteration = get_next_iteration(csv_file)
    update_csv(csv_file, new_data, iteration)

if __name__ == "__main__":
    main()


def get_next_iteration(csv_file):
    if not os.path.exists(csv_file):
        return 1
    with open(csv_file, mode='r') as file:
        reader = csv.reader(file)
        headers = next(reader, [])
        iterations = [int(h.replace('iteration', '')) for h in headers if h.startswith('iteration')]
            
        return max(iterations, default=0) + 1

def update_csv(csv_file, new_data, iteration):
    existing_data = {}
    try:
        with open(csv_file, mode='r') as file:
            reader = csv.DictReader(file)
            for row in reader:
                existing_data[row['name']] = row
    except FileNotFoundError:
        pass
    
    for name, value in new_data.items():
        if name in existing_data:
            existing_data[name][f'iteration{iteration}'] = value
        else:
            existing_data[name] = {'name': name, f'iteration{iteration}': value}
    
    fieldnames = ['name'] + sorted([f'iteration{i}' for i in range(1, iteration + 1)], key=lambda x: int(x.replace('iteration', '')))
    
    with open(csv_file, mode='w', newline='') as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        for row in existing_data.values():
            writer.writerow(row)

def main():
    report_file_path = '/home/hemanth/sandlogic/sandlogic/testing/genus1.log'  
    csv_file = 'output.csv'
    
    with open(report_file_path, 'r') as file:
        report_text = file.read()
    
    new_data = parse_report(report_text)
    iteration = get_next_iteration(csv_file)
    update_csv(csv_file, new_data, iteration)

if __name__ == "__main__":
    main()
