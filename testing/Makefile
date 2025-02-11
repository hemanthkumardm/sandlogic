Makefile:
VERSION=21.1.0
VPATH=
TCLSH=/pkg/cadence-pvs-/20.10.000/i686-linux/tools.lnx86/bin/64bit/tclsh
GEN_FLOW=FF/SCRIPTS/gen_flow.tcl
SETUP_PATH=.
TOOL=bsub -R "rusage [mem=50000]" -Ip innovus
ARGS=-64 -cds_lib_file cds.lib
FSTEPS=init place cts postcts_hold route postroute postroute_hold signoff
SCRIPTS=FF
LOG=LOG

STEPS = version setup init place cts postcts_hold route postroute postroute_hold signoff do_cleanup
FF_START = init
FF_STOP = signoff

all: version setup init place cts postcts_hold route postroute postroute_hold signoff do_cleanup

version:
	@echo "# Foundation Flows Version $(VERSION)"

help:
	@echo "==================================================="
	@echo "           $(VERSION)  Foundation Flows"
	@echo "==================================================="
	@echo "   Makefile Targets"
	@echo "==================================================="
	@echo "               setup : Setup Run Directory"
	@echo                  init : Design Import / Initialization               
	@echo                 place : Cell Placement                               
	@echo                   cts : Clock Tree Synthesis                         
	@echo          postcts_hold : PostCTS Hold Fixing                          
	@echo                 route : Global/Detail Route                          
	@echo             postroute : PostRoute Optimization                       
	@echo        postroute_hold : PostRoute Hold Fixing                        
	@echo               signoff : Signoff Timing / Verify                      
	@echo "---------------------------------------------------"
	@echo "                 all : All design steps"
	@echo "              simple : Single script (all steps in a single session) - no stop/start"
	@echo "              single : Single script (all steps in a single session)"
	@echo "==================================================="
	@echo "   Makefile Options"
	@echo "==================================================="
	@echo "   VPATH : Make directory    (default make)"
	@echo "    TOOL : INNOVUS executable     (default innovus)"
	@echo "    ARGS : INNOVUS arguments      (default -nowin -64)"
	@echo "  UPDATE : Update scripts    (default yes)"
	@echo " SCRIPTS : Script directory  (default FF)"
	@echo "     LOG : Logfile directory (default LOG)"
	@echo "==================================================="


simple: setup
	FF_STOP=$(FF_STOP); VPATH=$(VPATH); export VPATH; $(TOOL) -init $(SCRIPTS)/INNOVUS/run_simple.tcl -log $(LOG)/simple.log $(ARGS)


single: setup
	FF_STOP=$(FF_STOP); VPATH=$(VPATH); export VPATH; $(TOOL) -init $(SCRIPTS)/INNOVUS/run_all.tcl -log $(LOG)/single.log $(ARGS)

setup:
	@/bin/mkdir -p $(VPATH) $(LOG)
	@/bin/touch $(VPATH)/$@

init: setup
	@mkdir -p $(LOG);
	VPATH=$(VPATH); export VPATH; $(TOOL) -init $(SCRIPTS)/INNOVUS/run_init.tcl -log $(LOG)/init.log -overwrite $(ARGS)
place: init
	@mkdir -p $(LOG);
	VPATH=$(VPATH); export VPATH; $(TOOL) -init $(SCRIPTS)/INNOVUS/run_place.tcl -log $(LOG)/place.log -overwrite $(ARGS)
cts: place
	@mkdir -p $(LOG);
	VPATH=$(VPATH); export VPATH; $(TOOL) -init $(SCRIPTS)/INNOVUS/run_cts.tcl -log $(LOG)/cts.log -overwrite $(ARGS)
postcts_hold: cts
	@mkdir -p $(LOG);
	VPATH=$(VPATH); export VPATH; $(TOOL) -init $(SCRIPTS)/INNOVUS/run_postcts_hold.tcl -log $(LOG)/postcts_hold.log -overwrite $(ARGS)
route: postcts_hold
	@mkdir -p $(LOG);
	VPATH=$(VPATH); export VPATH; $(TOOL) -init $(SCRIPTS)/INNOVUS/run_route.tcl -log $(LOG)/route.log -overwrite $(ARGS)
postroute: route
	@mkdir -p $(LOG);
	VPATH=$(VPATH); export VPATH; $(TOOL) -init $(SCRIPTS)/INNOVUS/run_postroute.tcl -log $(LOG)/postroute.log -overwrite $(ARGS)
postroute_hold: postroute
	@mkdir -p $(LOG);
	VPATH=$(VPATH); export VPATH; $(TOOL) -init $(SCRIPTS)/INNOVUS/run_postroute_hold.tcl -log $(LOG)/postroute_hold.log -overwrite $(ARGS)
signoff: postroute_hold
	@mkdir -p $(LOG);
	VPATH=$(VPATH); export VPATH; $(TOOL) -init $(SCRIPTS)/INNOVUS/run_signoff.tcl -log $(LOG)/signoff.log -overwrite $(ARGS)