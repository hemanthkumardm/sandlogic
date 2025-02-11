

# Design Information
set DESIGN_NAME "UDP"
set PROCESS_NODE "25"                
set REPORTS_DIR "../reports"

################################################################################
## Design Input                                                                #
################################################################################
set INIT_DESIGN_INPUT "verilog" 
set VERILOG_NETLIST_FILE "/data/project/tjazz/180nm/project_libs/IMG_MANTIS/netlist/mantis_core_dft_wrapper_v17.gv"
set SDC_FILE "/data/project/tjazz/180nm/project_libs/IMG_MANTIS/apr/sdc/mantis_core_dft_wrapper_wo_clk_unc.sdc"
set FUNC_SDC "$SDC_FILE"
set SCAN_SDC "$SDC_FILE"

# Timing and Constraints
set FUNC_TYP_SDC ""
set SCAN_SLOW_SDC ""
set SCAN_FAST_SDC ""
set INIT_MMMC_FILE ""
set FUNC_CLKSDC_FILE ""
set SCAN_CLKSDC_FILE ""
set IS_CLK_SPEC 0

# Floorplan and IO
set DEF_FILE ""
set FLOORPLAN_FILE ""
set IO_FILE ""
set CREATE_PWRGRID 0
set LOAD_INITIAL_ID_TCL_FILE 0
set LOAD_FINAL_ID_TCL_FILE 0
set ADD_TAPCELL 0
set OA_DATABASE 0
set GUARD_RING 0
set IS_METAL_ECO 0

# Analysis Options
set EM_ANALYSIS 0
set IR_ANALYSIS 0

# Library Files
set TARGET_LIBRARY_FILES "/data/project/tjazz/180nm/external_ips/tsl18fs190svt_wb_Rev_2022.12/lib/liberty/tsl18fs190svt_wb_ss_1p62v_125c.lib"
set MIN_LIBRARY_FILES "/data/project/tjazz/180nm/external_ips/tsl18fs190svt_wb_Rev_2022.12/lib/liberty/tsl18fs190svt_wb_ff_1p98v_m40c.lib"
set TYPICAL_LIBRARY_FILES ""
set LIBRARY_LEF_FILES "/data/project/tjazz/180nm/external_ips/tsl18fs190svt_wb_Rev_2022.12/tech/lef/6M1L/tsl18fs190svt_wb.lef"

# Parasitic Extraction
set QRC_TECH_FILE "/data/project/tjazz/180nm/external_ips/tsl18fs190svt_wb_Rev_2022.12/tech/lef/6M1L/qrcTechFile"
set CAP_TABLE_MAX_FILE ""
set CAP_TABLE_MIN_FILE ""

# Floorplan Defaults (If No DEF File is Available)
set ASPECT_RATIO 1
set CORE_UTILIZATION 0.65

# Encounter Variables
set FE_DESIGN_LIBRARY "DESIGN"
set SOCE_STRATEGY "qor"
set MAX_ROUTING_LAYER "6"
set FILLER_CELLS {FILLER_X16_18_SVT_WB FILLER_X1_18_SVT_WB FILLER_X2_18_SVT_WB FILLER_X32_18_SVT_WB FILLER_X4_18_SVT_WB FILLER_X8_18_SVT_WB}
set ALL_DCAP_CELLS {FILLCAP_X16_18_SVT_WB FILLCAP_X32_18_SVT_WB FILLCAP_X4_18_SVT_WB FILLCAP_X64_18_SVT_WB FILLCAP_X8_18_SVT_WB}
set ALL_ACTIVE_CELLS {}

# GDS Mapping
set GDS2MAP "/library/pdk/tower_semi_0.18um_CIS/tsl18fs190svt_wb_Rev_2018.06/tech/lef/6M1L/gds2_fe_6l.map"
set GDS_FILES "/library/pdk/tower_semi_0.18um_CIS/tsl18fs190svt_wb_Rev_2018.06/lib/gds/tsl18fs190svt_wb.gds"

# CPU Allocation
setMultiCpuUsage -localCpu 8

# Initialization
set init_remove_assigns 1
set init_assign_buffer {1 -buffer BUF_X4_18_SVT_WB -prefix buf_dummy}

# Set Design Mode
setDesignMode -process $PROCESS_NODE
