onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tf_sift_feat/clk_sys
add wave -noupdate -radix hexadecimal /tf_sift_feat/rst_sys
add wave -noupdate -radix hexadecimal /tf_sift_feat/din
add wave -noupdate -radix hexadecimal /tf_sift_feat/max
add wave -noupdate -radix hexadecimal /tf_sift_feat/min
add wave -noupdate -radix hexadecimal /tf_sift_feat/dout_kp
add wave -noupdate -radix hexadecimal /tf_sift_feat/mag
add wave -noupdate -radix hexadecimal /tf_sift_feat/dir
add wave -noupdate -radix hexadecimal /tf_sift_feat/out_en
add wave -noupdate -radix hexadecimal /tf_sift_feat/complete1
add wave -noupdate -radix hexadecimal /tf_sift_feat/complete2
add wave -noupdate -radix hexadecimal /tf_sift_feat/addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {110000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {105 us}
