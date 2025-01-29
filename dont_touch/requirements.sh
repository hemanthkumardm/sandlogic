#! /bin/bash 

read -p "Enter the design name: " DESIGN_NAME

BASE_DIR=$(pwd)/$DESIGN_NAME

DESIGN_NAME="$DESIGN_NAME"
RTL_DIR="$BASE_DIR/rtl"
LIB_DIR="$BASE_DIR/libs"
SDC_DIR="$BASE_DIR/sdc"
RPT_DIR="$BASE_DIR/reports"
OUT_DIR="$BASE_DIR/outputs"
LOG_DIR="$BASE_DIR/logs"
SCRIPTS_DIR="$BASE_DIR/scripts"

mkdir -p $RTL_DIR $LIB_DIR $SDC_DIR $RPT_DIR $OUT_DIR $LOG_DIR $SCRIPTS_DIR

cat > asic_config.yaml <<EOL
$DESIGN_NAME:
    asic_flow:
        synthesis:
            script: "run_sythesis.tcl"
            rtl_path: "$RTL_DIR"
            lib_path: "$LIB_DIR"
            sdc_path: "$SDC_DIR"
            report_path: "$RPT_DIR"
            output_path: "$OUT_DIR"
            log_path: "$LOG_DIR"
            scripts_path: "$SCRIPTS_DIR"
EOL

echo "ASIC synthesis enironment set up successfully"
echo "Created directories under: $BASE_DIR"
echo "Updated asic_config.yaml with paths"
