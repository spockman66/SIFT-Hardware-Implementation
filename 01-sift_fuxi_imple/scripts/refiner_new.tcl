##############################################################################
# PROJECT ENVIRONMENT
##############################################################################
# INCENTIA = /cygdrive/D/CreateIC/Fuxi/Software/ast_frontend
# AST_FRONTEND = /cygdrive/D/CreateIC/Fuxi/Software/ast_frontend
# ARCH_TYPE = P1
# USE_ACE_ARCH = 
# USE_RGRAPH_ARCH = D:/CreateIC/Fuxi/Software/andara/csdata/P1/rgraph/rgraph_arch
# USE_RGRAPH_DELAY = D:/CreateIC/Fuxi/Software/andara/csdata/P1/rgraph/rgraph_delay
# CSDATA = D:/CreateIC/Fuxi/Software/andara/csdata/P1
# CSLIBS = D:/CreateIC/Fuxi/Software/andara/cslibs/P1
# CSTOOLS = D:/CreateIC/Fuxi/Software/andara/cstools/devC
# CSTESTS = D:/CreateIC/Fuxi/Software/andara/cstests/devC
##############################################################################
# PROJECT VARIABLES
##############################################################################
set design           RISCV_P1_TOP
set arch             griffin
set arch_ver         2.0
set speed_grade      -3
set pvt_factor       1
puts "ANDARA: ###############################"
puts "ANDARA: # Starting step: refiner_new "
puts "ANDARA: ###############################"
set step refiner_new
set inFile netlist/chip_assigner.v
set outFile netlist/chip_refiner.v
set outDbFile db/chip_refiner.db
set sdcFile [list "constraint/RISCV_P1_TOP.sdc" "$env(CSTESTS)/lib/special.sdc" "$env(AGATE_ROOT)/bin/template/project/propagated_clock.sdc"]
set apafile outputs/RISCV_P1_TOP.apx
set andara_ver 5.1.2
set dev_name P1P060N0V324C7
set apvfile outputs/RISCV_P1_TOP.apv
set delayType max
set use_assigner 1
set refinerClockAdjust 200
set region_constraint_file "region_file"
set double_set_of_reg_ctrl_signal 1
source "$env(CSTOOLS)/scripts/cswitch/refiner_new.tcl"
catch {exec reportProgress 8 100 3}
puts "ANDARA: ###############################"
puts "ANDARA: # Ending step: refiner_new "
puts "ANDARA: ###############################"