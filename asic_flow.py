import subprocess
import yaml
import os
 
def load_config():
    """Loads the ASIC flow configuration from asic_config.yaml."""
    try:
        with open("asic_config.yaml", "r") as file:
            config = yaml.safe_load(file)
        return config
    except FileNotFoundError:
        print("Error: Configuration file 'asic_config.yaml' not found.")
        exit(1)
 
def run_synthesis():
    """Runs the synthesis process using Cadence Genus."""
    
    # Load configuration
    config = load_config()
    synthesis_config = config["udp"]["asic_flow"]["synthesis"]
    
    script = synthesis_config["udp"]["script"]
    log_file = synthesis_config["udp"]["log_file"]
    
    # Ensure the script exists
    if not os.path.exists(script):
        print(f"Error: TCL script '{script}' not found.")
        exit(1)
 
    print(f"Running synthesis using Cadence Genus...")
    
    # Run Genus with the provided script and capture logs
    try:
        with open(log_file, "w") as log:
            result = subprocess.run(
                ["genus", "-legacy_ui", "-f", script],
                stdout=log,
                stderr=log,
                check=True
            )
        print("Synthesis completed successfully. Check logs for details.")
    except subprocess.CalledProcessError:
        print(f"Error: Synthesis failed. Check '{log_file}' for details.")
        exit(1)
 
if __name__ == "__main__":
    run_synthesis()
