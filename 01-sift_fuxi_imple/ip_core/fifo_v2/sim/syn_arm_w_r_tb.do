#Creat a work lib
vlib work

#Map the work lib to current lib
vmap work work

#Compile the source files
vlog -sv -f fifo_ahb_tb_modelsim.f +define+DUMP 

#Start simulator
vsim -sva -novopt work.syn_arm_w_r_tb

#Add wave
add wave -hex /syn_arm_w_r_tb/*

#run
run -all
#quit -f
