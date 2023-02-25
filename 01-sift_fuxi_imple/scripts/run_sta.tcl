## PROGRAM "Fuxi"
## VERSION "Version fx2020a win64"
##
## Device: P1P060N0V324C7

set design          RISCV_P1_TOP
set inFile          "RISCV_P1_TOP.arvx"
set inSdfFile       "RISCV_P1_TOP_router.sdf"
set sdcFile         [list "../constraint/RISCV_P1_TOP.sdc" "$env(AGATE_ROOT)/bin/template/project/propagated_clock.sdc"]
set report_file     "RISCV_P1_TOP.trpt"
set lib_file        "$env(AGATE_ROOT)/andara/csdata/P1/arch/general/fabric_timing.lib"
set extlib_tcl_file "$env(AGATE_ROOT)/data/csta/scripts/P1_extlib.tcl"
set max_path        500
source "$env(AGATE_ROOT)/bin/template/project/scripts/run_sta.tcl"