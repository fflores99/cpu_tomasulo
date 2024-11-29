onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /frontend_tb/clk
add wave -noupdate /frontend_tb/rst
add wave -noupdate /frontend_tb/UUT/DPCH_UNIT/ifq_pc
add wave -noupdate -divider cdb
add wave -noupdate /frontend_tb/cdb/tag
add wave -noupdate /frontend_tb/cdb/valid
add wave -noupdate /frontend_tb/cdb/data
add wave -noupdate /frontend_tb/cdb/branch
add wave -noupdate /frontend_tb/cdb/branch_taken
add wave -noupdate /frontend_tb/cdb/jalr
add wave -noupdate /frontend_tb/cdb/store_pc
add wave -noupdate -divider ifq-dpch-if
add wave -noupdate /frontend_tb/UUT/DPCH_UNIT/ifq_icode
add wave -noupdate /frontend_tb/UUT/DPCH_UNIT/ifq_empty
add wave -noupdate /frontend_tb/UUT/DPCH_UNIT/dpch_jmp_br_addr
add wave -noupdate /frontend_tb/UUT/DPCH_UNIT/dpch_rd
add wave -noupdate /frontend_tb/UUT/DPCH_UNIT/dpch_jmp
add wave -noupdate -divider queues
add wave -noupdate /frontend_tb/queue_op1_data
add wave -noupdate /frontend_tb/queue_op1_tag
add wave -noupdate /frontend_tb/queue_op1_data_valid
add wave -noupdate /frontend_tb/queue_op2_data
add wave -noupdate /frontend_tb/queue_op2_tag
add wave -noupdate /frontend_tb/queue_op2_data_valid
add wave -noupdate /frontend_tb/queue_rd_tag
add wave -noupdate /frontend_tb/queue_rd_tag_valid
add wave -noupdate /frontend_tb/queue_funct3
add wave -noupdate /frontend_tb/queue_alu_en
add wave -noupdate /frontend_tb/queue_alu_ext
add wave -noupdate /frontend_tb/queue_agu_en
add wave -noupdate /frontend_tb/queue_agu_ls
add wave -noupdate /frontend_tb/queue_agu_imm
add wave -noupdate /frontend_tb/queue_mul_en
add wave -noupdate /frontend_tb/queue_div_en
add wave -noupdate -divider {reg file}
add wave -noupdate /frontend_tb/UUT/DPCH_UNIT/REG_FILE/REG_OUT_ARRAY
add wave -noupdate -divider RST
add wave -noupdate /frontend_tb/UUT/DPCH_UNIT/REG_ST_TBL/REGISTER_STATUS
add wave -noupdate -divider {fetch queue}
add wave -noupdate -expand /frontend_tb/UUT/IFQ/BUFF/BUFF_DAT
add wave -noupdate -divider debug
add wave -noupdate /frontend_tb/UUT/DPCH_UNIT/ctrl_reg_w
add wave -noupdate /frontend_tb/UUT/DPCH_UNIT/nstall
add wave -noupdate -radix decimal /frontend_tb/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {298470 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 199
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {291350 ps} {396350 ps}
