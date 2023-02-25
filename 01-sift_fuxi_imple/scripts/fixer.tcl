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
puts "ANDARA: # Starting step: fixer "
puts "ANDARA: ###############################"
set step fixer
set inFile netlist/chip_refiner.v
set outFile netlist/chip_fixer.v
set outDbFile db/chip_fixer.db
set sdcFile [list "constraint/RISCV_P1_TOP.sdc" "$env(CSTESTS)/lib/special.sdc" "$env(AGATE_ROOT)/bin/template/project/propagated_clock.sdc"]
set placerMode wire_timing
set numberPaths 500
set delayType max
set outSdcFile { }
set fixerClockAdjust 200
catch {exec reportProgress 16 0 3}
source "$env(CSTOOLS)/scripts/cswitch/fixer.tcl"
catch {exec reportProgress 16 20 3}
puts "ANDARA: ###############################"
puts "ANDARA: # Ending step: fixer "
puts "ANDARA: ###############################"