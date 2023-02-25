set_option dev P1P060N0V324C7
set_option v "src/sift/sift_top.v" "ip_core/uart/include/hme_uart_config.vh" "ip_core/uart/include/hme_uart_const.vh" "src/led_ctrl.v" "src/sift/block2_27extreme.v" "src/sift/block3x3.v" "src/sift/block3x3_2.v" "src/sift/block11x11.v" "src/sift/block11x11_2.v" "src/sift/CONV.v" "src/sift/cov.v" "src/sift/DoG.v" "src/sift/local_extreme.v" "src/sift/mag_calc.v" "src/sift/mag_dir_calc.v" "src/sift/my_fifo2.v" "src/sift/my_fifo256.v" "src/sift/shift_register_3.v" "src/sift/shift_register_15.v" "src/sift/sift_feat.v" "src/mul_new2.v" "src/dma/uiFDMA.v" "src/ram_image.v" "src/pll_sift.v" "src/dma/dma_if.v" "src/RISCV_P1_TOP.v" "src/ddrv1/ddr_v1.v" "src/clk_rst_manage.v" "src/soc_wrap.v" "src/pll_main.v" "src/timer.v" "src/fifo2ddr.v" "src/fifo2ddr_emb_v1.v" "src/enc_HME_VEX_SOC_V1.v" "ip_core/uart/enc_hme_uart_top.v" "ip_core/spi/enc_hme_spi_v3.v" "ip_core/gpio/enc_hme_gpio_v3.v" "ip_core/iic/enc_hme_apb_i2c_top.v" "src/dbg_core1.v" "ip_core/ddr_v1/src/ccb_ddr_cfg_top.v" "ip_core/ddr_v1/src/check_ddr_cfg_done.v" "ip_core/ddr_v1/src/array2ddr_mux.v" "ip_core/fifo_v2/src/syn_fifo.v" "ip_core/fifo_v2/src/asyn_fifo.v" "ip_core/dwip_v2_1/src/dwip.v"
set_option top RISCV_P1_TOP
set_option vo outputs/RISCV_P1_TOP.amv
set_option whitebox true
set_option isyn true
set_option fca true
set_option keep_latch true
set_option keep_floating true
set_option optimize_primitives true
set_option shift_register_inference false
set_option shift_register_merge false
set_option fast_io false
set_option aoc outputs/RISCV_P1_TOP_ast.aoc
set_option min_ce_fanout 4
set_option carry_opt true
set_option magic true
set_option mode fast
set_option use_dsp auto
set_option use_naming_rule true
set_option cfe scripts/cfe.tcl
set_option reg_opt true
set_option memory_threshold 1024
set_option min_adder_width 6
set_option remove_identical_inst true
set_option disioc false
set_option extract_multiport_rams true
set_option max_fanout 20

source "$env(AGATE_ROOT)/data/syn/cst_flow.tcl"