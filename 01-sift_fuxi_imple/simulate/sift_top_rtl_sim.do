transcript on
if {[file exists rtl_work]} {
    vdel -lib rtl_work -all
}
vlib rtl_work
vmap -c work rtl_work
vlog -vlog01compat -work work D:/CreateIC/Fuxi/Software/data/lib/p1_sim.v
vlog -vlog01compat -work work +protect "D:/CreateIC/00_sift/simulate/../ip_core/fifo_v2/src/syn_fifo.v" "D:/CreateIC/00_sift/simulate/../ip_core/fifo_v2/src/asyn_fifo.v"
vlog -vlog01compat -work work  "D:/CreateIC/00_sift/src/sift/sift_top.v" "D:/CreateIC/00_sift/ip_core/uart/include/hme_uart_config.vh" "D:/CreateIC/00_sift/ip_core/uart/include/hme_uart_const.vh" "D:/CreateIC/00_sift/src/led_ctrl.v" "D:/CreateIC/00_sift/src/sift/block2_27extreme.v" "D:/CreateIC/00_sift/src/sift/block3x3.v" "D:/CreateIC/00_sift/src/sift/block3x3_2.v" "D:/CreateIC/00_sift/src/sift/block11x11.v" "D:/CreateIC/00_sift/src/sift/block11x11_2.v" "D:/CreateIC/00_sift/src/sift/CONV.v" "D:/CreateIC/00_sift/src/sift/cov.v" "D:/CreateIC/00_sift/src/sift/DoG.v" "D:/CreateIC/00_sift/src/sift/local_extreme.v" "D:/CreateIC/00_sift/src/sift/mag_calc.v" "D:/CreateIC/00_sift/src/sift/mag_dir_calc.v" "D:/CreateIC/00_sift/src/sift/my_fifo2.v" "D:/CreateIC/00_sift/src/sift/my_fifo256.v" "D:/CreateIC/00_sift/src/sift/shift_register_3.v" "D:/CreateIC/00_sift/src/sift/shift_register_15.v" "D:/CreateIC/00_sift/src/sift/sift_feat.v" "D:/CreateIC/00_sift/src/mul_new2.v" "D:/CreateIC/00_sift/src/dma/uiFDMA.v" "D:/CreateIC/00_sift/src/ram_image.v" "D:/CreateIC/00_sift/src/pll_sift.v" "D:/CreateIC/00_sift/src/dma/dma_if.v" "D:/CreateIC/00_sift/src/RISCV_P1_TOP.v" "D:/CreateIC/00_sift/src/ddrv1/ddr_v1.v" "D:/CreateIC/00_sift/src/clk_rst_manage.v" "D:/CreateIC/00_sift/src/soc_wrap.v" "D:/CreateIC/00_sift/src/pll_main.v" "D:/CreateIC/00_sift/src/timer.v" "D:/CreateIC/00_sift/src/fifo2ram.v" "D:/CreateIC/00_sift/src/fifo2ram_emb_v1.v" "D:/CreateIC/00_sift/src/fifo2ddr.v" "D:/CreateIC/00_sift/src/fifo2ddr_emb_v1.v" "D:/CreateIC/00_sift/src/sift_tb/tf_sift_feat.v" +initreg+0
vcom -93 -work work +protect "D:/CreateIC/00_sift/simulate/../ip_core/ddr_v1/"
vsim -voptargs=+acc work.tf_sift_feat 
add wave -hex *