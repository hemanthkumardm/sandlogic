import os
import json
import shutil
import subprocess


#-------------------------------------------- creating dir -------------------------------------------#

def create_directories_and_move_files(design_name):

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


    print (" ░▒▓███████▓▒░  ▒▓██████▓▒   ▓███████▓▒  ▒▓███████▓▒  ▒▓█▓▒        ▒▓██████▓▒   ▒▓██████▓▒  ▒▓█▓▒  ▒▓██████▓▒░   ")
    print (" ░▒▓█▓▒░      ░▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒░░▒▓█▓▒ ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒░  ") 
    print (" ░▒▓█▓▒░      ░▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒░       ▒▓█▓▒ ▒▓█▓▒          ")
    print (" ░▒▓██████▓▒░ ░▒▓████████▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒▒▓███▓▒ ▒▓█▓▒ ▒▓█▓▒          ")
    print ("       ░▒▓█▓▒ ░▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒░░▒▓█▓▒ ▒▓█▓▒ ▒▓█▓▒          ")
    print ("       ░▒▓█▓▒ ░▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒░░▒▓█▓▒ ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒░  ")
    print (" ░▒▓███████▓▒ ░▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓███████▓▒  ▒▓████████▓▒ ▒▓██████▓▒   ▒▓██████▓▒  ▒▓█▓▒  ▒▓██████▓▒░   ")
                                                                                                               
                                                                                                             

    design_name = input("Enter the design name: ")
    user_name = input("enter your name")
    user_email = input("enter your email")
    paths, config_file = create_directories_and_move_files(design_name)

    env = os.environ.copy()
    for key, path in paths.items():
        env[key.upper() + "_PATH"] = path  

    config = load_config(config_file)

    while True:
        stage = input("Select stage to run (rtl/synthesis): ").strip().lower()
        
        if stage == "rtl":
            run_rtl(config, env)
            break
        elif stage == "synthesis":
            while True:
                effort = input("Select effort level for synthesis (low, medium, high): ").strip().lower()
                if effort in ["low", "medium", "high"]:
                    run_synthesis(config, env, effort)
                    break
                else:
                    print("Invalid input. Please enter 'low', 'medium', or 'high'.")
            break
        else:
            print("Invalid input. Please enter 'rtl' or 'synthesis'.")
