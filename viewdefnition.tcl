create_library_set -name --------\
-timing\
[list ./timing/------\
./timing/-------------\
./timing/--------------\
./timing/------------\
./timing/--------------]
create_library_set -name ------\
-timing\
[list ./timing/---------\
list ./timing/---------]
create_library_set -name -------------\
-timing\
[list ./-------------b\
./timing/---------------\
./timing/------------\
./timing/------------------\
./timing/tpzn65lpgv2bc.lib]
create_op_cond -name PM_wc_virtual -library_file \
./timing/tcbn45gsbwpwc.lib -P 1 -V 0.81 -T 125
create_op_cond -name PM_bc_virtual -library_file \
./timing/tcbn45gsbwpbc.lib -P 1 -V 0.99 -T 0
create_rc_corner -name rc_cworst \
-cap_table worst.CapTbl
create_delay_corner -name AV_PM_on_dc\
-library_set wc_0v81\
-opcond_library tcbn45gsbwpwc\
-opcond PM_wc_virtual -rc_corner rc_cworst
update_delay_corner -name AV_PM_on_dc -power_domain PDdefault\
-library_set wc_0v81_1\
-opcond_library tcbn45gsbwpwc\
-opcond PM_wc_virtual
update_delay_corner -name AV_PM_on_dc -power_domain PD1\
-library_set wc_0v81\
-opcond_library tcbn45gsbwpwc\
-opcond PM_wc_virtual
update_delay_corner -name AV_PM_on_dc -power_domain PD2\
-library_set wc_0v81\
-opcond_library tcbn45gsbwpwc\
-opcond PM_wc_virtual
update_delay_corner -name AV_PM_on_dc -power_domain PD3\
-library_set wc_0v81_1\
-opcond_library tcbn45gsbwpwc\
-opcond PM_wc_virtual