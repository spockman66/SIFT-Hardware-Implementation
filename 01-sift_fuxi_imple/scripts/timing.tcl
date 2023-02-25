## PROGRAM "Fuxi"
## VERSION "Version fx2020a win64"
##
## Device: P1P060N0V324C7

set design          RISCV_P1_TOP
set inFile          "outputs/RISCV_P1_TOP.arv"
set inSdfFile       "outputs/RISCV_P1_TOP_router.sdf"
set sdcFile         [list "constraint/RISCV_P1_TOP.sdc" "$env(AGATE_ROOT)/bin/template/project/propagated_clock.sdc"]
set report_file     "outputs/RISCV_P1_TOP_cstool.trpt"
set extlib_tcl_file "$env(AGATE_ROOT)/data/csta/scripts/P1_extlib.tcl"
set max_path        500
source "$env(CSTOOLS)/scripts/cswitch/cs_timing.tcl"