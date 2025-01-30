import os
import yaml
import subprocess

def load_config(config_file="asic_config.yaml"):
    """Load configuration from YAML file."""
    with open(config_file, "r") as file:
        return yaml.safe_load(file)

def run_synthesis(config):
    """Run synthesis flow using the provided config."""
    design_name = list(config.keys())[0]
    paths = config[design_name]['asic_flow']['synthesis']
    
    log_file = os.path.join(paths['log_path'], "synthesis.log")
    error_file = os.path.join(paths['log_path'], "synthesis.err")
    
    script_path = os.path.join(paths['scripts_path'], "run_synthesis.tcl")
    command = ["genus", "-legacy_ui", "-files", script_path]
    
    with open(log_file, "w") as log, open(error_file, "w") as err:
        process = subprocess.run(command, cwd=paths['scripts_path'], stdout=log, stderr=err)
    
    if process.returncode == 0:
        print("Synthesis completed successfully. Logs stored in", log_file)
    else:
        print("Synthesis encountered errors. Check", error_file)

if __name__ == "__main__":
    config = load_config()
    run_synthesis(config)
