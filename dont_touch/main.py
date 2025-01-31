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

    # Create the ASIC configuration JSON file
    config_file = os.path.join(design_dir, f"{design_name}_config.json")
    asic_config = {
        design_name: {
            "asic_flow": {
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

def load_config(config_file):
    """Loads configuration from JSON file."""
    with open(config_file, "r") as file:
        return json.load(file)

def run_stage(config, env, stage):
    """Runs the specified stage (RTL or synthesis) using a TCL script."""
    
    design_name = list(config.keys())[0]
    stage_config = config[design_name]['asic_flow'][stage]

    script_path = os.path.join(stage_config['scripts_path'], stage_config['script'])
    log_file = os.path.join(stage_config['log_path'], f"{stage}.log")
    error_file = os.path.join(stage_config['log_path'], f"{stage}.err")

    env["DESIGN_NAME"] = design_name

    # Set environment variables for TCL
    for key, path in stage_config.items():
        if key.endswith("_path"):
            env[key.upper()] = path  # Convert to uppercase like RTL_PATH

    # Debugging: Print environment variables
    print(f"\nRunning {stage} stage for {design_name}...")
    for key, value in env.items():
        if "PATH" in key:
            print(f"{key}={value}")

    command = ["tclsh", script_path]

    with open(log_file, "w") as log, open(error_file, "w") as err:
        process = subprocess.run(command, cwd=stage_config['scripts_path'], stdout=log, stderr=err, env=env)

    if process.returncode == 0:
        print(f"{stage.capitalize()} completed successfully. Check logs for details.")
    else:
        print(f"Errors occurred. Check {error_file}")

if __name__ == "__main__":


    print (" ░▒▓███████▓▒░  ▒▓██████▓▒   ▓███████▓▒  ▒▓███████▓▒  ▒▓█▓▒        ▒▓██████▓▒   ▒▓██████▓▒  ▒▓█▓▒  ▒▓██████▓▒░   ")
    print (" ░▒▓█▓▒░      ░▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒░░▒▓█▓▒ ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒░  ") 
    print (" ░▒▓█▓▒░      ░▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒░       ▒▓█▓▒ ▒▓█▓▒          ")
    print (" ░▒▓██████▓▒░ ░▒▓████████▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒▒▓███▓▒ ▒▓█▓▒ ▒▓█▓▒          ")
    print ("       ░▒▓█▓▒ ░▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒░░▒▓█▓▒ ▒▓█▓▒ ▒▓█▓▒          ")
    print ("       ░▒▓█▓▒ ░▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒░░▒▓█▓▒ ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒░  ")
    print (" ░▒▓███████▓▒ ░▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓███████▓▒  ▒▓████████▓▒ ▒▓██████▓▒   ▒▓██████▓▒  ▒▓█▓▒  ▒▓██████▓▒░   ")
                                                                                                               
                                                                                                             

    design_name = input("Enter the design name: ")

    # Create directories, move files, and generate config
    paths, config_file = create_directories_and_move_files(design_name)

    # Set environment variables for the TCL script
    env = os.environ.copy()
    for key, path in paths.items():
        env[key.upper() + "_PATH"] = path  

    # Load the configuration
    config = load_config(config_file)

    # Ask user which stage to run (RTL or synthesis)
    while True:
        stage = input("Enter stage to run (rtl/synthesis): ").strip().lower()
        if stage in ["rtl", "synthesis"]:
            break
        print("Invalid input. Please enter 'rtl' or 'synthesis'.")

    # Run the selected stage
    run_stage(config, env, stage)
