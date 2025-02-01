import tkinter as tk
from tkinter import messagebox
import os
import json
import shutil
import subprocess
import datetime
import pandas as pd
import threading
from tkinter import simpledialog


def load_user_data(csv_file):
    df = pd.read_csv(csv_file)
    user_dict = {}
    for _, row in df.iterrows():
        user_dict[row["name"]] = {
            "email": row["email"],
            "password": row["password"],
            "rtl": row["rtl"].strip().lower() == "yes",
            "synthesis": row["synthesis"].strip().lower() == "yes",
            "lec": row["lec"].strip().lower() == "yes",
            "pnr": row["pnr"].strip().lower() == "yes"

        }
    return user_dict

# Load users at startup

user_data = load_user_data("details.csv")

# Function to generate a timestamped filename
def get_timestamped_filename(base_filename):
    timestamp = datetime.datetime.now().strftime("%d-%m-%y-%H-%M-%S")
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

    file_mappings = {'.v': paths["rtl"], '.sv': paths["rtl"], '.tcl': paths["scripts"], 
                     '.sdc': paths["sdc"], '.lib': paths["libs"], '.lef': paths["libs"], '.tf': paths["libs"]}

    for ext, target_dir in file_mappings.items():
        for file in os.listdir(base_dir):
            if file.endswith(ext):
                source = os.path.join(base_dir, file)
                target = os.path.join(target_dir, file)
                shutil.copy(source, target)
                print(f"Moved {file} to {target_dir}")

#------------------------------------------------------- config.json ---------------------------------$

    config_file = os.path.join(design_dir, f"{design_name}_config.json")
    asic_config = {
        design_name: {
            "asic_flow": {
                "user_details": {
                    "user_name": user_name,
                    "user_email": user_email,
                    "default_emails": ["abc@sandlogic.com", "xyz@sandlogic.com", "123@sandlogic.com"]
                },
                "rtl": {
                    "design_name": design_name,
                    "script": "run_rtl.tcl",
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
                    "script": "run_lec.tcl",
                    "netlist": paths["netlist"],
                    "rtl_path": paths["rtl"],
                    "lib_path": paths["libs"],
                    "sdc_path": paths["sdc"],
                    "report_path": paths["reports"],
                    "output_path": paths["outputs"],
                    "log_path": paths["logs"],
                    "scripts_path": paths["scripts"]
                },
                "placeNroute": {
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

#--------------------------------------------- running rtl ----------------------------#

def run_rtl(config, env):
    design_name = list(config.keys())[0]
    rtl_config = config[design_name]['asic_flow']['rtl']

    script_path = os.path.join(rtl_config['scripts_path'], rtl_config['script'])
    log_file = os.path.join(rtl_config['log_path'], get_timestamped_filename("rtl.log"))
    error_file = os.path.join(rtl_config['log_path'], get_timestamped_filename("rtl.err"))

    env["DESIGN_NAME"] = design_name
    for key, path in rtl_config.items():
        if key.endswith("_path"):
            env[key.upper()] = path  

    print(f"\nRunning RTL stage for {design_name}...")

    command = ["tclsh", script_path]

    with open(log_file, "w") as log, open(error_file, "w") as err:
        process = subprocess.run(command, cwd=rtl_config['scripts_path'], stdout=log, stderr=err, env=env)

    if process.returncode == 0:
        print("RTL completed successfully. Check logs for details.")
    else:
        print(f"Errors occurred in RTL stage. Check {error_file}")

#--------------------------------------------------- running synthesis --------------------------------------------#


def run_synthesis(config, env, effort):
    
    design_name = list(config.keys())[0]
    synthesis_config = config[design_name]['asic_flow']['synthesis']

    script_path = os.path.join(synthesis_config['scripts_path'], synthesis_config['script'])
    log_file = os.path.join(synthesis_config['log_path'], get_timestamped_filename("synthesis.log"))
    error_file = os.path.join(synthesis_config['log_path'], get_timestamped_filename("synthesis.err"))

    env["DESIGN_NAME"] = design_name
    env["EFFORT_LEVEL"] = effort  # Pass effort level to the synthesis environment

    # Set environment variables for TCL
    for key, path in synthesis_config.items():
        if key.endswith("_path"):
            env[key.upper()] = path  

    print(f"\nRunning synthesis stage for {design_name} with {effort} effort level...")

    # Command to run the TCL script
    command = ["tclsh", script_path]

    with open(log_file, "w") as log, open(error_file, "w") as err:
        process = subprocess.run(command, cwd=synthesis_config['scripts_path'], stdout=log, stderr=err, env=env)

    if process.returncode == 0:
        print("Synthesis completed successfully. Check logs for details.")
    else:
        print(f"Errors occurred in synthesis stage. Check {error_file}")



#--------------------------------------------------- lec --------------------------------------------#


def run_lec(config, env):
    
    design_name = list(config.keys())[0]
    lec_config = config[design_name]['asic_flow']['lec']

    script_path = os.path.join(lec_config['scripts_path'], lec_config['script'])
    log_file = os.path.join(lec_config['log_path'], get_timestamped_filename("lec.log"))
    error_file = os.path.join(lec_config['log_path'], get_timestamped_filename("lec.err"))

    env["DESIGN_NAME"] = design_name
    # env["EFFORT_LEVEL"] = effort  # Pass effort level to the synthesis environment

    # Set environment variables for TCL
    for key, path in lec_config.items():
        if key.endswith("_path"):
            env[key.upper()] = path  

    print(f"\nRunning lec stage for {design_name}")

    # Command to run the TCL script
    command = ["tclsh", script_path]

    with open(log_file, "w") as log, open(error_file, "w") as err:
        process = subprocess.run(command, cwd=lec_config['scripts_path'], stdout=log, stderr=err, env=env)

    if process.returncode == 0:
        print("LEC completed successfully. Check logs for details.")
    else:
        print(f"Errors occurred in synthesis stage. Check {error_file}")

        
#--------------------------------------------------- pnr --------------------------------------------#


def run_pnr(config, env, effort):
    
    design_name = list(config.keys())[0]
    pnr_config = config[design_name]['asic_flow']['pnr']

    script_path = os.path.join(pnr_config['scripts_path'], pnr_config['script'])
    log_file = os.path.join(pnr_config['log_path'], get_timestamped_filename("pnr.log"))
    error_file = os.path.join(pnr_config['log_path'], get_timestamped_filename("pnr.err"))

    env["DESIGN_NAME"] = design_name
    # env["EFFORT_LEVEL"] = effort  # Pass effort level to the pnr environment

    # Set environment variables for TCL
    for key, path in pnr_config.items():
        if key.endswith("_path"):
            env[key.upper()] = path  

    print(f"\nRunning PNR stage for {design_name}")

    # Command to run the TCL script
    command = ["tclsh", script_path]

    with open(log_file, "w") as log, open(error_file, "w") as err:
        process = subprocess.run(command, cwd=pnr_config['scripts_path'], stdout=log, stderr=err, env=env)

    if process.returncode == 0:
        print("PNR completed successfully. Check logs for details.")
    else:
        print(f"Errors occurred in PNR stage. Check {error_file}")

        


if __name__ == "__main__":
    print (" Started Automation......")



root = tk.Tk()
root.config(bg="lightgray")
root.title("ASIC Flow Automation")
root.geometry("1050x850")


# ASCII Art Text
ascii_art = """
 ░▒▓███████▓▒░  ▒▓██████▓▒   ▓███████▓▒  ▒▓███████▓▒  ▒▓█▓▒        ▒▓██████▓▒   ▒▓██████▓▒  ▒▓█▓▒  ▒▓██████▓▒░   
 ░▒▓█▓▒░      ░▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒░░▒▓█▓▒ ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒░  
 ░▒▓█▓▒░      ░▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒░       ▒▓█▓▒ ▒▓█▓▒          
 ░▒▓██████▓▒░ ░▒▓████████▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒▒▓███▓▒ ▒▓█▓▒ ▒▓█▓▒          
       ░▒▓█▓▒ ░▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒░░▒▓█▓▒ ▒▓█▓▒ ▒▓█▓▒          
       ░▒▓█▓▒ ░▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒░░▒▓█▓▒ ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒░  
 ░▒▓███████▓▒ ░▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓███████▓▒  ▒▓████████▓▒ ▒▓██████▓▒   ▒▓██████▓▒  ▒▓█▓▒  ▒▓██████▓▒░   
"""


# Create a Text widget to display the ASCII art
ascii_text = tk.Text(root, height=9, width=113)
ascii_text.pack(pady=20)
ascii_text.insert(tk.END, ascii_art)
ascii_text.config(state=tk.DISABLED)

tk.Label(root, text="Select Your Name:", fg="blue", font=("Helvetica", 12, "bold"), bg="lightgray").pack(pady=(20, 10))

# Dropdown for selecting the name
name_var = tk.StringVar()

# OptionMenu for selecting name with better styling
name_dropdown = tk.OptionMenu(root, name_var, *user_data.keys())
name_dropdown.config(font=("Helvetica", 12), width=30, bg="white", fg="black", relief="solid")
name_dropdown.pack(pady=10)
# name_entry = tk.Entry(root, width=50)
# name_entry.pack()

tk.Label(root, text="Your Email:", fg="blue", font=("Helvetica", 12, "bold"), bg="lightgray").pack(pady=(20, 10))
email_entry = tk.Entry(root, width=50, state="readonly")
email_entry.pack()

# Define a dictionary to store the design checkboxes
design_names = ["udp", "rdmi", "flexicore"]
design_vars = {}

design_frame = tk.Frame(root)
design_frame.pack()

# Add checkboxes for each design name
tk.Label(root, text="Select Design Name:", fg="blue", font=("Helvetica", 12, "bold"), bg="lightgray").pack(pady=(20, 10))

for design in design_names:
    design_vars[design] = tk.BooleanVar()
    tk.Checkbutton(root, text=design, variable=design_vars[design], fg="green").pack()


tk.Label(root, text="Select Flow:", fg="blue", font=("Helvetica", 12, "bold"), bg="lightgray").pack(pady=(20, 10))

rtl_var = tk.BooleanVar()
synthesis_var = tk.BooleanVar()
lec_var = tk.BooleanVar()
pnr_var = tk.BooleanVar()
rtl_check = tk.Checkbutton(root, text="RTL Flow", variable=rtl_var, fg="red")
synthesis_check = tk.Checkbutton(root, text="Synthesis Flow", variable=synthesis_var, fg="red")
lec_check = tk.Checkbutton(root, text="LEC Flow", variable=lec_var, fg="red")
pnr_check = tk.Checkbutton(root, text="PNR Flow", variable=pnr_var, fg="red")
rtl_check.pack()
synthesis_check.pack()
lec_check.pack()
pnr_check.pack()


# Label for "Select Effort Level"
tk.Label(root, text="Select Effort Level:", fg="blue", font=("Helvetica", 12, "bold"), bg="lightgray").pack(pady=(20, 10))

# OptionMenu for selecting effort level with styling
effort_var = tk.StringVar(value="medium")
effort_options = ["low", "medium", "high"]
effort_dropdown = tk.OptionMenu(root, effort_var, *effort_options)

# Styling the dropdown
effort_dropdown.config(font=("Helvetica", 12), width=30, bg="white", fg="black", relief="solid")
effort_dropdown.pack(pady=10)


def on_name_select(event=None):
    selected_name = name_var.get()
    if selected_name in user_data:
        email_entry.config(state="normal")
        email_entry.delete(0, tk.END)
        email_entry.insert(0, user_data[selected_name]["email"])
        email_entry.config(state="readonly")  # Make it uneditable

        # Enable/Disable flow options
        rtl_var.set(user_data[selected_name]["rtl"])
        synthesis_var.set(user_data[selected_name]["synthesis"])
        lec_var.set(user_data[selected_name]["lec"])
        pnr_var.set(user_data[selected_name]["pnr"])

        rtl_check.config(state="normal" if user_data[selected_name]["rtl"] else "disabled")
        synthesis_check.config(state="normal" if user_data[selected_name]["synthesis"] else "disabled")
        lec_check.config(state="normal" if user_data[selected_name]["lec"] else "disabled")
        pnr_check.config(state="normal" if user_data[selected_name]["pnr"] else "disabled")


# Attach the event to the name dropdown
# name_dropdown.bind("<configure>", on_name_select)
name_var.trace_add("write", lambda *args: on_name_select(None))


# Function to execute ASIC flow
def execute_flow(user_data):
    design_name = user_data["design_name"]
    user_name = user_data["user_name"]
    user_email = user_data["user_email"]
    paths, config_file = create_directories_and_move_files(design_name, user_name, user_email)

    env = os.environ.copy()
    for key, path in paths.items():
        env[key.upper() + "_PATH"] = path  

    config = load_config(config_file)

    # Execute selected flows
    if user_data["rtl_selected"]:
        run_rtl(config, env)
    
    if user_data["synthesis_selected"]:
        run_synthesis(config, env, user_data["effort_level"])
    
    if user_data["lec_selected"]:
        run_lec(config, env)
    
    if user_data["pnr_selected"]:
        run_pnr(config, env)

def execute_async(user_data):
    threading.Thread(target=execute_flow, args=(user_data,)).start()

# Confirm and Execute
def confirm_and_execute():
    user_name = name_var.get()
    user_email = email_entry.get()
    # design_name = design_entry.get()
    rtl_selected = rtl_var.get() and user_data[user_name]["rtl"]
    synthesis_selected = synthesis_var.get() and user_data[user_name]["synthesis"]
    lec_selected = lec_var.get() and user_data[user_name]["lec"]
    pnr_selected = pnr_var.get() and user_data[user_name]["pnr"]
    effort_level = effort_var.get()

    # Validate input
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

        # Check if exactly one design is selected
    selected_designs = [design for design, var in design_vars.items() if var.get()]
    if len(selected_designs) != 1:
        messagebox.showerror("Error", "Please select exactly one design.")
        return
    
    design_name = selected_designs[0]  # Get the selected design name

    selected_flows = []
    if rtl_selected:
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
    """
    
    if messagebox.askyesno("Confirm Details", confirmation_message):
        root.destroy()  # Close GUI before execution
        execute_async({
            "user_name": user_name,
            "user_email": user_email,
            "design_name": design_name,
            "rtl_selected": rtl_selected,
            "synthesis_selected": synthesis_selected,
            "lec_selected": lec_selected,
            "pnr_selected": pnr_selected,
            "effort_level": effort_level
        })
        

tk.Button(root, text="Submit", command=confirm_and_execute, fg="white", bg="darkblue").pack()

root.mainloop()
