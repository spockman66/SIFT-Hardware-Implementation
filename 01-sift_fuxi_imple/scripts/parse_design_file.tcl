####################################################
# PARSE DESIGN CONFIGURATION
####################################################
set top_design RISCV_P1_TOP
set include_path {"." "src/sift" "ip_core/uart/include" "src" "src/dma" "src/ddrv1" "ip_core/uart" "ip_core/spi" "ip_core/gpio" "ip_core/iic" "ip_core/ddr_v1/src" "ip_core/fifo_v2/src" "ip_core/dwip_v2_1/src"}
set verilog_design_files {"src/sift/sift_top.v" "ip_core/uart/include/hme_uart_config.vh" "ip_core/uart/include/hme_uart_const.vh" "src/led_ctrl.v" "src/sift/block2_27extreme.v" "src/sift/block3x3.v" "src/sift/block3x3_2.v" "src/sift/block11x11.v" "src/sift/block11x11_2.v" "src/sift/CONV.v" "src/sift/cov.v" "src/sift/DoG.v" "src/sift/local_extreme.v" "src/sift/mag_calc.v" "src/sift/mag_dir_calc.v" "src/sift/my_fifo2.v" "src/sift/my_fifo256.v" "src/sift/shift_register_3.v" "src/sift/shift_register_15.v" "src/sift/sift_feat.v" "src/mul_new2.v" "src/dma/uiFDMA.v" "src/ram_image.v" "src/pll_sift.v" "src/dma/dma_if.v" "src/RISCV_P1_TOP.v" "src/ddrv1/ddr_v1.v" "src/clk_rst_manage.v" "src/soc_wrap.v" "src/pll_main.v" "src/timer.v" "src/fifo2ddr.v" "src/fifo2ddr_emb_v1.v" "src/enc_HME_VEX_SOC_V1.v" "ip_core/uart/enc_hme_uart_top.v" "ip_core/spi/enc_hme_spi_v3.v" "ip_core/gpio/enc_hme_gpio_v3.v" "ip_core/iic/enc_hme_apb_i2c_top.v" "src/dbg_core1.v" "ip_core/ddr_v1/src/ccb_ddr_cfg_top.v" "ip_core/ddr_v1/src/check_ddr_cfg_done.v" "ip_core/ddr_v1/src/array2ddr_mux.v" "ip_core/fifo_v2/src/syn_fifo.v" "ip_core/fifo_v2/src/asyn_fifo.v" "ip_core/dwip_v2_1/src/dwip.v"}
set bbox_lib "$env(AGATE_ROOT)/data/lib/cst_lib_p1.v"
setmsgtype -ignore {VERI-1012}
setmsgtype -error {VERI-1466}
setmsgtype -error {VERI-1084}
if {[info exists vhdl_design_files]} {
    source "$env(AGATE_ROOT)/data/syn/cfe/init_vhdl_lib.tcl"
    parse_design -work work -format vhdl -vhdl_2008 -vhdl_sort ${vhdl_design_files} -incdir ${include_path} -v ${bbox_lib}
}
if {[info exists verilog_design_files]} {
    parse_design -work work -format verilog ${verilog_design_files} -incdir ${include_path} -v ${bbox_lib} 
}
dump_design_info -work work -format "verilog" -dump "D:/CreateIC/Final/03-sift_fuxi_imple/outputs/RISCV_P1_TOP_design_info.xml" -top "RISCV_P1_TOP"
exit 0