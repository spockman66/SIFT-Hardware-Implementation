

#Cswitch floor planner placed instances

cs_place -forcearch griffin-2.0 clk_rst_manage_ins_pll_main_pll_u0 C65R24.u0_clk_spine.c0r0_gclk_tile.c0r0_gclk_gen.pll
cs_place -forcearch griffin-2.0 u_dbg_u_tap_genblk1_u_jtag C65R48.u0_soc.u0_jtag_dbw
cs_place -forcearch griffin-2.0 u_ddr_v1_u_inst_u_ddr23phy C128R81.u_ddr_tile.ddr.u_ddr.u_phy_wrap
cs_place -forcearch griffin-2.0 u_ddr_v1_u_inst_u_ddrc C128R81.u_ddr_tile.ddr.u_ddr.u_ctl_wrap
cs_place -forcearch griffin-2.0 u_ddr_v1_u_inst_u_ddrc_crg C128R81.u_ddr_crg.u_ddr_crg_core
cs_place -forcearch griffin-2.0 u_sift_clk_manager_pll_u0 C65R27.u0_clk_spine.c0r0_gclk_tile.c0r1_gclk_gen.pll