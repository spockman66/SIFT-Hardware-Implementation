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
puts "ANDARA: # Starting step: route "
puts "ANDARA: ###############################"
set step route
set inDbFile       db/chip_pack.db
set inSdcFile      [list "constraint/RISCV_P1_TOP.sdc" "$env(CSTESTS)/lib/special.sdc" "$env(AGATE_ROOT)/bin/template/project/propagated_clock.sdc"]
set ntiming_paths  500
set routeLog       outputs/chip_rte.ro
set outDbFile      db/chip_rte.db
set outFile        netlist/chip_rte.v
set arafile        outputs/RISCV_P1_TOP.ara
set dev_name       P1P060N0V324C7
set outSdcFile     ""
set routeSdf       "outputs/RISCV_P1_TOP_router.sdf"
set apafile        outputs/RISCV_P1_TOP.apa
set arvfile        outputs/RISCV_P1_TOP.arv
set andara_ver     5.1.2
set delayType      max
cs_route_config MAX_ITER 45
cs_route_config  FUTURE_WEIGHT 95
cs_route_config RBUF_ANCHOR 0
set rgraph         "$env(USE_RGRAPH_ARCH)"
set rgraph_delay   "$env(USE_RGRAPH_DELAY)"
source "$env(CSTOOLS)/scripts/cswitch/route.tcl"
catch {exec reportProgress 16 100 3}
puts "ANDARA: ###############################"
puts "ANDARA: # Ending step: route "
puts "ANDARA: ###############################"