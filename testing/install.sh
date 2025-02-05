#!/bin/bash

# Check for Python3 and Pip installation
if ! command -v python3 &> /dev/null
then
    echo "Python3 is not installed. Please install Python3."
    exit 1
fi

if ! command -v pip3 &> /dev/null
then
    echo "Pip3 is not installed. Please install Pip3."
    exit 1
fi

# Set up virtual environment
echo "Setting up virtual environment..."
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate


# Install dependencies
echo "Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Run the automation script
echo "Running the automation script..."
python3 main.py

# Deactivate virtual environment after the script completes
deactivate

echo "Installation complete and automation executed!"

