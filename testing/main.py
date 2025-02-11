import tkinter as tk
from tkinter import messagebox
import os
import json
import shutil
import subprocess
import re
import datetime
import pandas as pd
import threading
from tkinter import simpledialog
from email.mime.base import MIMEBase
from email import encoders
from email.message import EmailMessage
import ssl
import smtplib



def load_user_data(csv_file):
    df = pd.read_csv(csv_file)
    user_dict = {}
    for _, row in df.iterrows():
        user_dict[row["name"]] = {
            "email": row["email"],
            "password": row["password"],
            "linting": row["linting"].strip().lower() == "yes",
            "synthesis": row["synthesis"].strip().lower() == "yes",
            "lec": row["lec"].strip().lower() == "yes",
            "pnr": row["pnr"].strip().lower() == "yes",
            "default_emails": row["default_emails"].split(' and ')

        }
    return user_dict

user_data = load_user_data("details.csv")


#------------------------------------------------ Start of mails-----------------------------------------#


def send_email(recipient_emails, subject, body, attachments=None):
    email_sender = "dmhemanthkumar7@gmail.com"
    email_password = os.getenv("EMAIL_PASSWORD")  

    em = EmailMessage()
    em["From"] = email_sender
    em["Subject"] = subject
    em.set_content(body)
    em["To"] = ', '.join(recipient_emails)

    if attachments:
        for attachment in attachments:

            if isinstance(attachment, tuple):
                file_path, file_type = attachment
            else:
                file_path = attachment
                file_type = "log" if "log" in file_path else "err"

            try:
                with open(file_path, 'rb') as f:
                    file_data = f.read()
                    base_name = file_path.split('/')[-1].rsplit('.', 1)[0]
                    file_name = f"{base_name}_{file_type}.txt"

                    em.add_attachment(file_data, maintype='text', subtype='plain', filename=file_name)
                    print(f"Attached file: {file_name}")
            except FileNotFoundError:
                print(f"File not found: {file_path}")

    context = ssl.create_default_context()
    with smtplib.SMTP_SSL('smtp.gmail.com', 465, context=context) as smtp:
        smtp.login(email_sender, email_password)
        smtp.sendmail(email_sender, recipient_emails, em.as_string())
        print(f"Email sent to: {recipient_emails}")

def send_flow_results(design_name, user_name, user_email, default_emails, log_file=None, error_file=None):
    
    subject = f"Automation Results for {design_name}"
    body = "Attached are the logs and error details for your automation flow."

    if not user_email:
        print("Error: User email is not provided.")
        return

    if isinstance(default_emails, str):
        default_emails = [default_emails]

    recipients = [user_email] + (default_emails if default_emails else [])

    attachments = []
    if log_file:
        attachments.append((log_file, "log"))
    if error_file:
        attachments.append((error_file, "err"))

    send_email(recipients, subject, body, attachments)



#------------------------------------------ END of mails---------------------------------------------#

# Function to generate a timestamped filename
def get_timestamped_filename(base_filename):
    timestamp = datetime.datetime.now().strftime("%d-%m-%H:%M:%S")
    return f"{timestamp}_{base_filename}"


#-------------------------------------------- creating dir -------------------------------------------#

def create_directories_and_move_files(design_name, user_name, user_email):

    base_dir = os.getcwd()
    design_dir = os.path.join(base_dir, design_name)
    
    paths = {
        "rtl": os.path.join(design_dir, "rtl"),
        "netlist": os.path.join(design_dir, "netlist"),
        "libs": os.path.join(design_dir, "libs"),
        "sdc": os.path.join(design_dir, "sdc"),
        "reports": os.path.join(design_dir, "reports"),
        "outputs": os.path.join(design_dir, "outputs"),
        "logs": os.path.join(design_dir, "logs"),
        "scripts": os.path.join(design_dir, "scripts")
    }

#----------------------------------------------------- checking dir -------------------------------------#
    if os.path.isdir(design_dir):
        print(f"Directory {design_dir} already exists. Moving files only.")
    else:
        print(f"Creating directory structure for {design_name}.")
        for path in paths.values():
            os.makedirs(path, exist_ok=True)



#------------------------------------------------------- moving files -----------------------------------#

    file_mappings = {'.v': paths["rtl"], '.sv': paths["rtl"], '.tcl': paths["scripts"], '.do': paths["scripts"],  
                     '.sdc': paths["sdc"], '.lib': paths["libs"], '.lef': paths["libs"], '.tf': paths["libs"], '.rpt': paths["reports"]}

    for ext, target_dir in file_mappings.items():
        for file in os.listdir(base_dir):
            if file.endswith(ext):
                source = os.path.join(base_dir, file)
                target = os.path.join(target_dir, file)
                shutil.copy(source, target)
                print(f"Moved {file} to {target_dir}")

#------------------------------------------------------- config.json ---------------------------------$

    config_file = os.path.join(design_dir, f"{user_name}_{design_name}_config.json")
    asic_config = {
        design_name: {
            "asic_flow": {
                "user_details": {
                    "user_name": user_name,
                    "user_email": user_email,
                },
                "linting": {
                    "design_name": design_name,
                    "script": "run_linting.tcl",
                    "rtl_path": paths["rtl"],
                    "lib_path": paths["libs"],
                    "report_path": paths["reports"],
                    "output_path": paths["outputs"],
                    "log_path": paths["logs"],
                    "scripts_path": paths["scripts"]
                },
                "synthesis": {
                    "design_name": design_name,
                    "script": "run_synthesis.tcl",
                    "netlist": paths["netlist"],
                    "rtl_path": paths["rtl"],
                    "lib_path": paths["libs"],
                    "sdc_path": paths["sdc"],
                    "report_path": paths["reports"],
                    "output_path": paths["outputs"],
                    "log_path": paths["logs"],
                    "scripts_path": paths["scripts"]
                },
                "lec": {
                    "design_name": design_name,
                    "script": "run_lec.do",
                    "netlist": paths["netlist"],
                    "rtl_path": paths["rtl"],
                    "lib_path": paths["libs"],
                    "sdc_path": paths["sdc"],
                    "report_path": paths["reports"],
                    "output_path": paths["outputs"],
                    "log_path": paths["logs"],
                    "scripts_path": paths["scripts"]
                },
                "pnr": {
                    "design_name": design_name,
                    "script": "run_pnr.tcl",
                    "netlist": paths["netlist"],
                    "rtl_path": paths["rtl"],
                    "lib_path": paths["libs"],
                    "sdc_path": paths["sdc"],
                    "report_path": paths["reports"],
                    "output_path": paths["outputs"],
                    "log_path": paths["logs"],
                    "scripts_path": paths["scripts"]
                }
            }
        }
    }

    with open(config_file, 'w') as json_file:
        json.dump(asic_config, json_file, indent=4)

    print("ASIC environment setup complete.")
    print(f"Configuration written to {config_file}.")

    return paths, config_file

#---------------------------------------------- load config -----------------------------#

def load_config(config_file):
    with open(config_file, "r") as file:
        return json.load(file)




#------------------------------------------------------------- under test ---------------------------------------------------------------#
#--------------------------------------------- running linting ----------------------------#
#------------------------------------------------------------- under test ---------------------------------------------------------------#
#------------------------------------------------------------- under test ---------------------------------------------------------------#
#------------------------------------------------------------- under test ---------------------------------------------------------------#
#------------------------------------------------------------- under test ---------------------------------------------------------------#
#------------------------------------------------------------- under test ---------------------------------------------------------------#
#------------------------------------------------------------- under test ---------------------------------------------------------------#

# def run_linting(config, env, user_name, user_email, default_emails):
#     design_name = list(config.keys())[0]
#     linting_config = config[design_name]['asic_flow']['linting']

#     script_path = os.path.join(linting_config['scripts_path'], linting_config['script'])
#     log_file = os.path.join(linting_config['log_path'], get_timestamped_filename("linting.log"))
#     error_file = os.path.join(linting_config['log_path'], get_timestamped_filename("linting.err"))

#     env["DESIGN_NAME"] = design_name
#     for key, path in linting_config.items():
#         if key.endswith("_path"):
#             env[key.upper()] = path  

#     print(f"\nRunning linting stage for {design_name}...")

#     command = ["jg", "-superlint", script_path]

#     with open(log_file, "w") as log, open(error_file, "w") as err:
#         process = subprocess.run(command, cwd=linting_config['scripts_path'], stdout=log, stderr=err, env=env)

#     if process.returncode == 0:
#         print("linting completed successfully. Check logs for details.")
#     else:
#         print(f"Errors occurred in linting stage. Check {error_file}")

#     send_flow_results(design_name, user_name, user_email, default_emails, log_file, error_file)

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

    return csv_file_path  # Return the updated CSV path

def run_linting(config, env, user_name, user_email, default_emails):
    """Runs the linting flow and stores logs & results."""
    design_name = list(config.keys())[0]
    linting_config = config[design_name]['asic_flow']['linting']

    script_path = os.path.join(linting_config['scripts_path'], linting_config['script'])
    log_file = os.path.join(linting_config['log_path'], get_timestamped_filename("linting.log"))
    error_file = os.path.join(linting_config['log_path'], get_timestamped_filename("linting.err"))
    csv_file = os.path.join(linting_config['log_path'], "linting_summary.csv")  # Fixed CSV file

    env["DESIGN_NAME"] = design_name
    for key, path in linting_config.items():
        if key.endswith("_path"):
            env[key.upper()] = path  

    print(f"\nRunning linting stage for {design_name}...")

    command = ["jg", "-superlint", script_path]

    with open(log_file, "w") as log, open(error_file, "w") as err:
        process = subprocess.Popen(command, cwd=linting_config['scripts_path'], stdout=log, stderr=err, env=env)

    if process.returncode == 0:
        print("Linting completed successfully. Parsing log file...")
    else:
        print(f"Errors occurred in linting stage. Check {error_file}")

    # Parse log file and update CSV with iterations
    new_data = parse_log_file(log_file)
    if new_data:
        parsed_csv = update_csv(csv_file, new_data)
    else:
        parsed_csv = log_file  # If no new data, send raw log instead

    # Send email with updated CSV
    send_flow_results(design_name, user_name, user_email, default_emails, parsed_csv, error_file)





#------------------------------------------------------------- under test ---------------------------------------------------------------#
#------------------------------------------------------------- under test ---------------------------------------------------------------#
#------------------------------------------------------------- under test ---------------------------------------------------------------#
#------------------------------------------------------------- under test ---------------------------------------------------------------#
#------------------------------------------------------------- under test ---------------------------------------------------------------#
#------------------------------------------------------------- under test ---------------------------------------------------------------#

#--------------------------------------------------- running synthesis --------------------------------------------#


def run_synthesis(config, env, effort, user_name, user_email, default_emails):
    
    design_name = list(config.keys())[0]
    synthesis_config = config[design_name]['asic_flow']['synthesis']

    script_path = os.path.join(synthesis_config['scripts_path'], synthesis_config['script'])
    log_file = os.path.join(synthesis_config['log_path'], get_timestamped_filename("synthesis.log"))
    error_file = os.path.join(synthesis_config['log_path'], get_timestamped_filename("synthesis.err"))

    env["DESIGN_NAME"] = design_name
    env["EFFORT_LEVEL"] = effort  

    for key, path in synthesis_config.items():
        if key.endswith("_path"):
            env[key.upper()] = path  

    print(f"\nRunning synthesis stage for {design_name} with {effort} effort level...")

    command = ["gneus", "-batch", "-file", script_path]

    with open(log_file, "w") as log, open(error_file, "w") as err:
        process = subprocess.Popen(command, cwd=synthesis_config['scripts_path'], stdout=log, stderr=err, env=env)

    if process.returncode == 0:
        print("Synthesis completed successfully. Check logs for details.")
    else:
        print(f"Errors occurred in synthesis stage. Check {error_file}")
    
    send_flow_results(design_name, user_name, user_email, default_emails, log_file, error_file)




#--------------------------------------------------- lec --------------------------------------------#


def run_lec(config, env, user_name, user_email, default_emails):
    
    design_name = list(config.keys())[0]
    lec_config = config[design_name]['asic_flow']['lec']

    script_path = os.path.join(lec_config['scripts_path'], lec_config['script'])
    log_file = os.path.join(lec_config['log_path'], get_timestamped_filename("lec.log"))
    error_file = os.path.join(lec_config['log_path'], get_timestamped_filename("lec.err"))

    env["DESIGN_NAME"] = design_name

    # Set environment variables for TCL
    for key, path in lec_config.items():
        if key.endswith("_path"):
            env[key.upper()] = path  

    print(f"\nRunning lec stage for {design_name}")

    command = ["lec", "-xl", "-nogui", "-do", script_path]

    with open(log_file, "w") as log, open(error_file, "w") as err:
        process = subprocess.Popen(command, cwd=lec_config['scripts_path'], stdout=log, stderr=err, env=env)

    if process.returncode == 0:
        print("LEC completed successfully. Check logs for details.")
    else:
        print(f"Errors occurred in synthesis stage. Check {error_file}")

    send_flow_results(design_name, user_name, user_email, default_emails, log_file, error_file)
        
#--------------------------------------------------- pnr --------------------------------------------#


def run_pnr(config, env, effort, user_name, user_email, default_emails):
    
    design_name = list(config.keys())[0]
    pnr_config = config[design_name]['asic_flow']['pnr']

    script_path = os.path.join(pnr_config['scripts_path'], pnr_config['script'])
    log_file = os.path.join(pnr_config['log_path'], get_timestamped_filename("pnr.log"))
    error_file = os.path.join(pnr_config['log_path'], get_timestamped_filename("pnr.err"))

    env["DESIGN_NAME"] = design_name
    env["EFFORT_LEVEL"] = effort 

    for key, path in pnr_config.items():
        if key.endswith("_path"):
            env[key.upper()] = path  

    print(f"\nRunning PNR stage for {design_name}")

    command = ["tclsh", script_path]

    with open(log_file, "w") as log, open(error_file, "w") as err:
        process = subprocess.Popen(command, cwd=pnr_config['scripts_path'], stdout=log, stderr=err, env=env)

    if process.returncode == 0:
        print("PNR completed successfully. Check logs for details.")
    else:
        print(f"Errors occurred in PNR stage. Check {error_file}")

    send_flow_results(design_name, user_name, user_email, default_emails, log_file, error_file)

if __name__ == "__main__":
    print (" Started Automation......")


#------------------------------------------ GUI variables ---------------------------------------------- #

root = tk.Tk()
root.config(bg="lightgray")
root.title("ASIC Flow Automation")
root.geometry("1050x850")

ascii_art = """
  ▒▓███████▓▒   ▒▓██████▓▒   ▓███████▓▒  ▒▓███████▓▒  ▒▓█▓▒        ▒▓██████▓▒   ▒▓██████▓▒  ▒▓█▓▒  ▒▓██████▓▒    
  ▒▓█▓▒        ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒   
  ▒▓█▓▒        ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒        ▒▓█▓▒ ▒▓█▓▒          
  ▒▓██████▓▒   ▒▓████████▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒▒▓███▓▒ ▒▓█▓▒ ▒▓█▓▒          
        ▒▓█▓▒  ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒ ▒▓█▓▒          
        ▒▓█▓▒  ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒   
  ▒▓███████▓▒  ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓███████▓▒  ▒▓████████▓▒ ▒▓██████▓▒   ▒▓██████▓▒  ▒▓█▓▒  ▒▓██████▓▒    
"""

ascii_text = tk.Text(root, height=9, width=113)
ascii_text.pack(pady=20)
ascii_text.insert(tk.END, ascii_art)
ascii_text.config(state=tk.DISABLED)

tk.Label(root, text="Select Your Name:", fg="blue", font=("Helvetica", 12, "bold"), bg="lightgray").pack(pady=(20, 10))

name_var = tk.StringVar()

name_dropdown = tk.OptionMenu(root, name_var, *user_data.keys())
name_dropdown.config(font=("Helvetica", 12), width=30, bg="white", fg="black", relief="solid")
name_dropdown.pack(pady=10)

tk.Label(root, text="Your Email:", fg="blue", font=("Helvetica", 12, "bold"), bg="lightgray").pack(pady=(20, 10))
email_entry = tk.Entry(root, width=50, state="readonly")
email_entry.pack()

design_names = ["udp", "rdmi", "flexicore"]
design_vars = {}

design_frame = tk.Frame(root)
design_frame.pack()

tk.Label(root, text="Select Design Name:", fg="blue", font=("Helvetica", 12, "bold"), bg="lightgray").pack(pady=(20, 10))

for design in design_names:
    design_vars[design] = tk.BooleanVar()
    tk.Checkbutton(root, text=design, variable=design_vars[design], fg="green").pack()


tk.Label(root, text="Select Flow:", fg="blue", font=("Helvetica", 12, "bold"), bg="lightgray").pack(pady=(20, 10))

linting_var = tk.BooleanVar()
synthesis_var = tk.BooleanVar()
lec_var = tk.BooleanVar()
pnr_var = tk.BooleanVar()
linting_check = tk.Checkbutton(root, text="Linting Flow", variable=linting_var, fg="red", state= 'normal')
synthesis_check = tk.Checkbutton(root, text="Synthesis Flow", variable=synthesis_var, fg="red", state= 'normal')
lec_check = tk.Checkbutton(root, text="LEC Flow", variable=lec_var, fg="red", state= 'normal')
pnr_check = tk.Checkbutton(root, text="PNR Flow", variable=pnr_var, fg="red", state= 'normal')
linting_check.pack()
synthesis_check.pack()
lec_check.pack()
pnr_check.pack()


tk.Label(root, text="Select Effort Level:", fg="blue", font=("Helvetica", 12, "bold"), bg="lightgray").pack(pady=(20, 10))

effort_var = tk.StringVar(value="medium")
effort_options = ["low", "medium", "high"]
effort_dropdown = tk.OptionMenu(root, effort_var, *effort_options)

effort_dropdown.config(font=("Helvetica", 12), width=30, bg="white", fg="black", relief="solid")
effort_dropdown.pack(pady=10)

forward_to_leaders_var = tk.BooleanVar()
forward_to_leaders_checkbox = tk.Checkbutton(root, text="Do you want to forward it to leaders?", variable=forward_to_leaders_var, fg="blue")
forward_to_leaders_checkbox.pack(pady=(10, 20))

# ------------------------------------------- END of GUI part ---------------------------------------------- #


# -------------------------------------------- GUI name selection ------------------------------------------- #
def on_name_select(event=None):
    selected_name = name_var.get()
    if selected_name in user_data:
        email_entry.config(state="normal")
        email_entry.delete(0, tk.END)
        email_entry.insert(0, user_data[selected_name]["email"])
        email_entry.config(state="readonly") 

        linting_var.set(user_data[selected_name]["linting"])
        synthesis_var.set(user_data[selected_name]["synthesis"])
        lec_var.set(user_data[selected_name]["lec"])
        pnr_var.set(user_data[selected_name]["pnr"])

        linting_check.config(state="normal" if user_data[selected_name]["linting"] else "disabled")
        synthesis_check.config(state="normal" if user_data[selected_name]["synthesis"] else "disabled")
        lec_check.config(state="normal" if user_data[selected_name]["lec"] else "disabled")
        pnr_check.config(state="normal" if user_data[selected_name]["pnr"] else "disabled")


name_var.trace_add("write", lambda *args: on_name_select(None))


# ------------------------------------------------ start the flow ------------------------------------------------- #

def execute_flow(user_data, effort_level, forward_to_leaders):
    design_name = user_data["design_name"]
    user_name = user_data["user_name"]
    user_email = user_data["user_email"]
    default_emails = user_data["default_emails"] if forward_to_leaders else []
    paths, config_file = create_directories_and_move_files(design_name, user_name, user_email)

    env = os.environ.copy()
    for key, path in paths.items():
        env[key.upper() + "_PATH"] = path  

    config = load_config(config_file)

    if user_data["linting_selected"]:
        run_linting(config, env, user_name, user_email, default_emails)
    
    if user_data["synthesis_selected"]:
        run_synthesis(config, env, effort_level, user_name, user_email, default_emails)
    
    if user_data["lec_selected"]:
        run_lec(config, env, user_name, user_email, default_emails)
    
    if user_data["pnr_selected"]:
        run_pnr(config, env, effort_level, user_name, user_email, default_emails)

def execute_async(user_data):
    threading.Thread(target=execute_flow, args=(user_data, effort_var.get(), forward_to_leaders_var.get())).start()

# ------------------------------------confirmation GUI ----------------------------------------- #

def confirm_and_execute():
    user_name = name_var.get()
    user_email = email_entry.get()
    linting_selected = linting_var.get() and user_data[user_name]["linting"]
    synthesis_selected = synthesis_var.get() and user_data[user_name]["synthesis"]
    lec_selected = lec_var.get() and user_data[user_name]["lec"]
    pnr_selected = pnr_var.get() and user_data[user_name]["pnr"]
    effort_level = effort_var.get()
    forward_to_leaders = forward_to_leaders_var.get()

    if not user_name or not user_email:
        messagebox.showerror("Error", "All fields must be filled!")
        return
    
    if user_name in user_data:
        password = simpledialog.askstring("Password", f"Enter password for {user_name}:", show='*')
        if password != user_data[user_name]["password"]:
            messagebox.showerror("Error", "Incorrect password!")
            return
    else:
        messagebox.showerror("Error", "User not found!")
        return

    selected_designs = [design for design, var in design_vars.items() if var.get()]
    if len(selected_designs) != 1:
        messagebox.showerror("Error", "Please select exactly one design.")
        return
    
    design_name = selected_designs[0] 

    selected_flows = []
    if linting_selected:
        selected_flows.append("RTL")
    if synthesis_selected:
        selected_flows.append("Synthesis")
    if lec_selected:
        selected_flows.append("LEC")
    if pnr_selected:
        selected_flows.append("pnr")    

    confirmation_message = f"""
    Name: {user_name}
    Email: {user_email}
    Design Name: {design_name}
    Selected Flows: {', '.join(selected_flows)}
    Effort Level: {effort_level}
    Forward to leaders: {"Yes" if forward_to_leaders else "No"}
    """
    
    if messagebox.askyesno("Confirm Details", confirmation_message):
        root.destroy()
        execute_async({
            "user_name": user_name,
            "user_email": user_email,
            "design_name": design_name,
            "linting_selected": linting_selected,
            "synthesis_selected": synthesis_selected,
            "lec_selected": lec_selected,
            "pnr_selected": pnr_selected,
            "effort_level": effort_level,
            "default_emails": user_data[user_name]["default_emails"],
        })

tk.Button(root, text="Submit", command=confirm_and_execute, fg="white", bg="darkblue").pack()

root.mainloop()


