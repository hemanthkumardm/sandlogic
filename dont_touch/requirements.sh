# #! /bin/bash

# read -p "Enter the design name: " DESIGN_NAME

# BASE_DIR=$(pwd)
# DESIGN_DIR=$BASE_DIR/$DESIGN_NAME

# RTL_DIR="$DESIGN_DIR/rtl"
# NETLIST_DIR="$DESIGN_DIR/netlist"
# LIB_DIR="$DESIGN_DIR/libs"
# SDC_DIR="$DESIGN_DIR/sdc"
# RPT_DIR="$DESIGN_DIR/reports"
# OUT_DIR="$DESIGN_DIR/outputs"
# LOG_DIR="$DESIGN_DIR/logs"
# SCRIPTS_DIR="$DESIGN_DIR/scripts"

# if [ -d "$DESIGN_DIR" ]; then
#     echo "Directory $DESIGN_DIR already exists. Moving files only."
# else
#     echo "Creating directory structure for $DESIGN_NAME."
#     mkdir -p $RTL_DIR $NETLIST_DIR $LIB_DIR $SDC_DIR $RPT_DIR $OUT_DIR $LOG_DIR $SCRIPTS_DIR
# fi

# mv $BASE_DIR/*.{v,sv} $RTL_DIR 2>/dev/null

# mv $BASE_DIR/*.{tcl} $SCRIPTS_DIR 2>/dev/null

# mv $BASE_DIR/*.sdc $SDC_DIR 2>/dev/null

# mv $BASE_DIR/*.{lib,lef,tf} $LIB_DIR 2>/dev/null

# input_file="asic_config.yaml"

# cat > asic_config.yaml <<EOL
# $DESIGN_NAME:
#     asic_flow:
#         synthesis:
#             script: "run_sythesis.tcl"
#             rtl_path: "$RTL_DIR"
#             lib_path: "$LIB_DIR"
#             sdc_path: "$SDC_DIR"
#             report_path: "$RPT_DIR"
#             output_path: "$OUT_DIR"
#             log_path: "$LOG_DIR"
#             scripts_path: "$SCRIPTS_DIR"
# EOL

# echo "ASIC synthesis environment setup complete."
# echo "Files moved to appropriate directories."


#! /bin/bash

read -p "Enter the design name: " DESIGN_NAME

BASE_DIR=$(pwd)
DESIGN_DIR=$BASE_DIR/$DESIGN_NAME

RTL_DIR="$DESIGN_DIR/rtl"
NETLIST_DIR="$DESIGN_DIR/netlist"
LIB_DIR="$DESIGN_DIR/libs"
SDC_DIR="$DESIGN_DIR/sdc"
RPT_DIR="$DESIGN_DIR/reports"
OUT_DIR="$DESIGN_DIR/outputs"
LOG_DIR="$DESIGN_DIR/logs"
SCRIPTS_DIR="$DESIGN_DIR/scripts"

if [ -d "$DESIGN_DIR" ]; then
    echo "Directory $DESIGN_DIR already exists. Moving files only."
else
    echo "Creating directory structure for $DESIGN_NAME."
    mkdir -p $RTL_DIR $NETLIST_DIR $LIB_DIR $SDC_DIR $RPT_DIR $OUT_DIR $LOG_DIR $SCRIPTS_DIR
fi

mv $BASE_DIR/*.{v,sv} $RTL_DIR 2>/dev/null
mv $BASE_DIR/*.{tcl} $SCRIPTS_DIR 2>/dev/null
mv $BASE_DIR/*.sdc $SDC_DIR 2>/dev/null
mv $BASE_DIR/*.{lib,lef,tf} $LIB_DIR 2>/dev/null

input_file="asic_config.json"

cat > asic_config.json <<EOL
{
    "$DESIGN_NAME": {
        "asic_flow": {
            "synthesis": {
                "script": "run_synthesis.tcl",
                "rtl_path": "$RTL_DIR",
                "lib_path": "$LIB_DIR",
                "sdc_path": "$SDC_DIR",
                "report_path": "$RPT_DIR",
                "output_path": "$OUT_DIR",
                "log_path": "$LOG_DIR",
                "scripts_path": "$SCRIPTS_DIR"
            }
        }
    }
}
EOL

echo "ASIC synthesis environment setup complete."
echo "Files moved to appropriate directories."