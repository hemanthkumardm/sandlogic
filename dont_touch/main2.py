import tkinter as tk
from tkinter import messagebox
import os
import json
import shutil
import subprocess


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
    log_file = os.path.join(rtl_config['log_path'], "rtl.log")
    error_file = os.path.join(rtl_config['log_path'], "rtl.err")

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
    log_file = os.path.join(synthesis_config['log_path'], "synthesis.log")
    error_file = os.path.join(synthesis_config['log_path'], "synthesis.err")

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


if __name__ == "__main__":


    print (" Started Automation......")

# Function to execute ASIC flow
def execute_flow(user_data):
    design_name = user_data["design_name"]
    user_name = user_data["user_name"]
    user_email = ["user_email"]
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

# Function to confirm and execute
def confirm_and_execute():
    user_data = {
        "user_name": name_entry.get(),
        "user_email": email_entry.get(),
        "design_name": design_entry.get(),
        "rtl_selected": rtl_var.get(),
        "synthesis_selected": synthesis_var.get(),
        "effort_level": effort_var.get()
    }

    # Validate input
    if not user_data["user_name"] or not user_data["user_email"] or not user_data["design_name"]:
        messagebox.showerror("Error", "All fields must be filled!")
        return

    confirmation_message = f"""
    Name: {user_data["user_name"]}
    Email: {user_data["user_email"]}
    Design Name: {user_data["design_name"]}
    Selected Flows: {'RTL' if user_data["rtl_selected"] else ''} {'Synthesis' if user_data["synthesis_selected"] else ''}
    Effort Level: {user_data["effort_level"]}
    """
    
    if messagebox.askyesno("Confirm Details", confirmation_message):
        root.destroy()  # Close GUI before execution
        paths, config_file = create_directories_and_move_files(user_data["design_name"],user_data["user_name"], user_data["user_email"])
        execute_flow(user_data)

root = tk.Tk()
root.title("ASIC Flow Automation")
root.geometry("1050x750")


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

# Insert the ASCII art into the Text widget
ascii_text.insert(tk.END, ascii_art)

# Disable editing of the Text widget
ascii_text.config(state=tk.DISABLED)

tk.Label(root, text="Enter Your Name:").pack()
name_entry = tk.Entry(root, width=50)
name_entry.pack()

tk.Label(root, text="Enter Your Email:").pack()
email_entry = tk.Entry(root, width=50)
email_entry.pack()

tk.Label(root, text="Enter Design Name:").pack()
design_entry = tk.Entry(root, width=50)
design_entry.pack()

rtl_var = tk.BooleanVar()
synthesis_var = tk.BooleanVar()
tk.Checkbutton(root, text="RTL Flow", variable=rtl_var).pack()
tk.Checkbutton(root, text="Synthesis Flow", variable=synthesis_var).pack()

tk.Label(root, text="Select Effort Level:").pack()
effort_var = tk.StringVar(value="medium")
effort_options = ["low", "medium", "high"]
tk.OptionMenu(root, effort_var, *effort_options).pack()

tk.Button(root, text="Submit", command=confirm_and_execute).pack()
root.mainloop()
