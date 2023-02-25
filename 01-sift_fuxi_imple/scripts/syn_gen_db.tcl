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
puts "ANDARA: # Starting step: syn_gen_db "
puts "ANDARA: ###############################"
set step syn_gen_db
set inSrcFile outputs/RISCV_P1_TOP.amv
set outDbFile db/chip_syn.db
catch {exec reportProgress 8 0 3}
source "$env(CSTOOLS)/scripts/cswitch/syn_gen_db.tcl"
catch {exec reportProgress 8 15 3}
puts "ANDARA: ###############################"
puts "ANDARA: # Ending step: syn_gen_db "
puts "ANDARA: ###############################"