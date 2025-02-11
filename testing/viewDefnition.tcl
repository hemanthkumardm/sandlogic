
create_constraint_mode -name functional -sdc_files DATA/asic_entity_func_fast_min.top.constr \
	 -ilm_sdc_files DATA/asic_entity_func_fast_min.top.constr
create_library_set -name fast_func_fast_min\
   -timing\
    [list .$LIB_PATH/fast.lib\
    .$LIB_PATH/pdkIO.lib\
    .$LIB_PATH/MEM2_4096X32_slow.lib\
    .$LIB_PATH/MEM2_2048X32_slow.lib\
    .$LIB_PATH/MEM2_1024X32_slow.lib\
    .$LIB_PATH/MEM1_4096X32_slow.lib\
    .$LIB_PATH/MEM1_1024X32_slow.lib\
    .$LIB_PATH/MEM1_256X32_slow.lib\
    .$LIB_PATH/MEM2_512X32_slow.lib\
    .$LIB_PATH/MEM2_136X32_slow.lib\
    .$LIB_PATH/MEM2_128X32_slow.lib\
    .$LIB_PATH/MEM2_128X16_slow.lib\
    $LIB_PATH/leon_func_fast_min.lib\
    $LIB_PATH/periph1_func_fast_min.lib]
create_rc_corner -name rc_min\
   -cap_table $LIB_PATH/captbl/worst/capTable\
   -preRoute_res 1.34236\
   -preRoute_cap 1.10066\
   -postRoute_res {0.994125}\
   -postRoute_cap {0.960235}\
   -postRoute_xcap {1.22327}\
   -preRoute_clkres 0\
   -preRoute_clkcap 1.105\
   -postRoute_clkres {0 0 0}\
   -postRoute_clkcap {0.969117 0 0}\
   -T 0\
   # -qx_tech_file ./libs/qx/qrcTechFile
create_delay_corner -name fast_min\
   -library_set fast_func_fast_min\
   -rc_corner rc_min
create_analysis_view -name func_fast_min -delay_corner fast_min -constraint_mode functional

create_constraint_mode -name functional_func_slow_max -sdc_files DATA/asic_entity_func_slow_max.top.constr \
	 -ilm_sdc_files DATA/asic_entity_func_slow_max.top.constr
create_library_set -name slow_func_slow_max\
   -timing\
    [list ./libs/lib/max/slow.lib\
    ./libs/lib/min/pdkIO.lib\
    ./libs/lib/min/MEM2_4096X32_slow.lib\
    ./libs/lib/min/MEM2_2048X32_slow.lib\
    ./libs/lib/min/MEM2_1024X32_slow.lib\
    ./libs/lib/min/MEM1_4096X32_slow.lib\
    ./libs/lib/min/MEM1_1024X32_slow.lib\
    ./libs/lib/min/MEM1_256X32_slow.lib\
    ./libs/lib/min/MEM2_512X32_slow.lib\
    ./libs/lib/min/MEM2_136X32_slow.lib\
    ./libs/lib/min/MEM2_128X32_slow.lib\
    ./libs/lib/min/MEM2_128X16_slow.lib\
    DATA/leon_func_slow_max.lib\
    DATA/periph1_func_slow_max.lib]
create_rc_corner -name rc_max\
   -cap_table ./libs/captbl/worst/capTable\
   -preRoute_res 1.34236\
   -preRoute_cap 1.10066\
   -postRoute_res {0.994125}\
   -postRoute_cap {0.960234}\
   -postRoute_xcap {1.22327}\
   -preRoute_clkres 0\
   -preRoute_clkcap 0.967898\
   -postRoute_clkres {0 0 0}\
   -postRoute_clkcap {0.969117 0 0}\
   -T 125\
   -qx_tech_file ./libs/qx/qrcTechFile
create_delay_corner -name slow_max\
   -library_set slow_func_slow_max\
   -rc_corner rc_max
create_analysis_view -name func_slow_max -delay_corner slow_max -constraint_mode functional_func_slow_max
set_analysis_view -setup [list func_slow_max] -hold [list func_fast_min]

source $SCRIPTS_PATH/asic_entity.nonsdc.constr
