import os
import json
import shutil
import subprocess

def create_directories_and_move_files(design_name):
    """Creates the necessary directory structure and moves files accordingly."""
    
    # Get the base directory and design directory
    base_dir = os.getcwd()
    design_dir = os.path.join(base_dir, design_name)
    
    # Directory paths
    rtl_dir = os.path.join(design_dir, "rtl")
    netlist_dir = os.path.join(design_dir, "netlist")
    lib_dir = os.path.join(design_dir, "libs")
    sdc_dir = os.path.join(design_dir, "sdc")
    rpt_dir = os.path.join(design_dir, "reports")
    out_dir = os.path.join(design_dir, "outputs")
    log_dir = os.path.join(design_dir, "logs")
    scripts_dir = os.path.join(design_dir, "scripts")

    # Check if the design directory exists; if not, create it
    if os.path.isdir(design_dir):
        print(f"Directory {design_dir} already exists. Moving files only.")
    else:
        print(f"Creating directory structure for {design_name}.")
        os.makedirs(rtl_dir, exist_ok=True)
        os.makedirs(netlist_dir, exist_ok=True)
        os.makedirs(lib_dir, exist_ok=True)
        os.makedirs(sdc_dir, exist_ok=True)
        os.makedirs(rpt_dir, exist_ok=True)
        os.makedirs(out_dir, exist_ok=True)
        os.makedirs(log_dir, exist_ok=True)
        os.makedirs(scripts_dir, exist_ok=True)

    # Copy files to appropriate directories
    for ext, target_dir in {'.v': rtl_dir, '.sv': rtl_dir, '.tcl': scripts_dir, '.sdc': sdc_dir, 
                            '.lib': lib_dir, '.lef': lib_dir, '.tf': lib_dir}.items():
        for file in os.listdir(base_dir):
            if file.endswith(ext):
                source = os.path.join(base_dir, file)
                target = os.path.join(target_dir, file)
                shutil.copy(source, target)
                print(f"Copied {file} to {target_dir}")

    # Create the ASIC configuration JSON file
    input_file = f"{design_name}_config.json"
    asic_config = {
        design_name: {
            "asic_flow": {
                "synthesis": {
                    "script": "run_synthesis.tcl",
                    "rtl_path": rtl_dir,
                    "lib_path": lib_dir,
                    "sdc_path": sdc_dir,
                    "report_path": rpt_dir,
                    "output_path": out_dir,
                    "log_path": log_dir,
                    "scripts_path": scripts_dir
                }
            }
        }
    }

    with open(input_file, 'w') as json_file:
        json.dump(asic_config, json_file, indent=4)

    print("ASIC synthesis environment setup complete.")
    print("Files copied to appropriate directories.")
    print(f"Configuration written to {input_file}.")

    return rtl_dir, lib_dir, sdc_dir, rpt_dir, out_dir, log_dir, scripts_dir

def load_config(config_file="asic_config.json"):
    """Loading configuration from JSON file."""
    with open(config_file, "r") as file:
        return json.load(file)

def run_synthesis(config, env):
    """Run synthesis flow using the provided config."""
    design_name = list(config.keys())[0]
    paths = config[design_name]['asic_flow']['synthesis']
    
    log_file = os.path.join(paths['log_path'], "synthesis.log")
    error_file = os.path.join(paths['log_path'], "synthesis.err")
    
    script_path = os.path.join(paths['scripts_path'], "run_synthesis.tcl")
    command = ["genus", "-batch", "-files", script_path]
    
    with open(log_file, "w") as log, open(error_file, "w") as err:
        process = subprocess.run(command, cwd=paths['scripts_path'], stdout=log, stderr=err, env=env)
    
    if process.returncode == 0:
        print("Synthesis completed successfully. Logs stored in", log_file)
    else:
        print("Synthesis encountered errors. Check", error_file)

if __name__ == "__main__":
    # Request design name
    design_name = input("Enter the design name: ")

    # Create directories, move files, and generate config
    rtl_dir, lib_dir, sdc_dir, rpt_dir, out_dir, log_dir, scripts_dir = create_directories_and_move_files(design_name)

    print(rtl_dir)
    # Set environment variables for the TCL script
    env = os.environ.copy()
    env["RTL_PATH"] = rtl_dir
    env["LIB_PATH"] = lib_dir
    env["SDC_PATH"] = sdc_dir
    env["REPORT_PATH"] = rpt_dir
    env["OUTPUT_PATH"] = out_dir
    env["LOG_PATH"] = log_dir
    env["SCRIPTS_PATH"] = scripts_dir

    # Load the configuration and run synthesis
    config = load_config(f"{design_name}_config.json")
    run_synthesis(config, env)
