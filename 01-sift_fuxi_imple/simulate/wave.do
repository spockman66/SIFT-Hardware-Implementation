onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tf_sift_feat/uut/U_DoG/blk1/cnt
add wave -noupdate /tf_sift_feat/uut/U_DoG/blk1/start_flag
add wave -noupdate /tf_sift_feat/uut/U_DoG/blk1/complete
add wave -noupdate /tf_sift_feat/uut/U_DoG/blk2/start_flag
add wave -noupdate /tf_sift_feat/uut/U_DoG/blk2/cnt
add wave -noupdate /tf_sift_feat/uut/U_DoG/blk2/complete
add wave -noupdate -radix decimal /tf_sift_feat/uut/U_local_extreme/min
add wave -noupdate -radix decimal /tf_sift_feat/uut/U_local_extreme/max
add wave -noupdate /tf_sift_feat/uut/U_local_extreme/dout
add wave -noupdate /tf_sift_feat/uut/U_local_extreme/out_en
add wave -noupdate /tf_sift_feat/uut/U_DoG/din
add wave -noupdate -radix unsigned /tf_sift_feat/uut/U_DoG/addr
add wave -noupdate /tf_sift_feat/uut/U_DoG/complete1
add wave -noupdate /tf_sift_feat/uut/U_DoG/complete2
add wave -noupdate /tf_sift_feat/uut/U_DoG/diff0
add wave -noupdate /tf_sift_feat/uut/U_DoG/diff1
add wave -noupdate /tf_sift_feat/uut/U_DoG/diff2
add wave -noupdate /tf_sift_feat/uut/U_DoG/dout1
add wave -noupdate /tf_sift_feat/uut/U_DoG/dout2
add wave -noupdate /tf_sift_feat/uut/U_DoG/dout3
add wave -noupdate /tf_sift_feat/uut/U_DoG/dout4
add wave -noupdate /tf_sift_feat/uut/U_DoG/out_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5334859435 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 320
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {4912258031 ps} {5573483503 ps}
