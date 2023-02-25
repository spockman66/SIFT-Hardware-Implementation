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
puts "ANDARA: # Starting step: fixer_drc "
puts "ANDARA: ###############################"
set step fixer_drc
set inSrcFile netlist/chip_fixer.v
set fixedCellFile scripts/fplan.fixed_cells.tcl
set dccPlcFile outputs/fixer_dcc_plc.csv
set dccShuntFile outputs/fixer_dcc_shunt.txt
source "$env(CSTOOLS)/scripts/cswitch/fixer_drc.tcl"
catch {exec reportProgress 16 40 3}
puts "ANDARA: ###############################"
puts "ANDARA: # Ending step: fixer_drc "
puts "ANDARA: ###############################"