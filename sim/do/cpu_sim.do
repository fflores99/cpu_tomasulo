onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLK /cpu_tb/clk
add wave -noupdate -label RST /cpu_tb/rst
add wave -noupdate -divider cdb
add wave -noupdate -color Turquoise -label TAG /cpu_tb/CPU/FRONTEND/cdb/tag
add wave -noupdate -color Turquoise -label VALID /cpu_tb/CPU/FRONTEND/cdb/valid
add wave -noupdate -color Turquoise -label DATA /cpu_tb/CPU/FRONTEND/cdb/data
add wave -noupdate -color Turquoise -label {BRANCH OPERATION} /cpu_tb/CPU/FRONTEND/cdb/branch
add wave -noupdate -color Turquoise -label {BRANCH TAKEN} /cpu_tb/CPU/FRONTEND/cdb/branch_taken
add wave -noupdate -color Turquoise -label {JUMP REGISTER (JALR)} /cpu_tb/CPU/FRONTEND/cdb/jalr
add wave -noupdate -color Turquoise -label {STORE PC} /cpu_tb/CPU/FRONTEND/cdb/store_pc
add wave -noupdate -divider {Reg file}
add wave -noupdate -color Coral -label {REGISTER FILE} /cpu_tb/CPU/FRONTEND/DPCH_UNIT/REG_FILE/REG_OUT_ARRAY
add wave -noupdate -divider mem
add wave -noupdate -color {Medium Slate Blue} -label {DATA ADDRESS} /cpu_tb/RAM/ADD
add wave -noupdate -color {Medium Slate Blue} -label {DATA WRITE ENABLE} /cpu_tb/RAM/we
add wave -noupdate -color {Medium Slate Blue} -label {DARA WRITE BUS} /cpu_tb/RAM/DW
add wave -noupdate -color {Medium Slate Blue} -label {DATA READ BUS} /cpu_tb/RAM/DR
add wave -noupdate -color Violet -radix hexadecimal {/cpu_tb/RAM/DATA_MEM[9]}
add wave -noupdate -color Violet -radix hexadecimal {/cpu_tb/RAM/DATA_MEM[8]}
add wave -noupdate -color Violet -radix hexadecimal {/cpu_tb/RAM/DATA_MEM[7]}
add wave -noupdate -color Violet -radix hexadecimal {/cpu_tb/RAM/DATA_MEM[6]}
add wave -noupdate -color Violet -radix hexadecimal {/cpu_tb/RAM/DATA_MEM[5]}
add wave -noupdate -color Violet -radix hexadecimal {/cpu_tb/RAM/DATA_MEM[4]}
add wave -noupdate -color Violet -radix hexadecimal {/cpu_tb/RAM/DATA_MEM[3]}
add wave -noupdate -color Violet -radix hexadecimal {/cpu_tb/RAM/DATA_MEM[2]}
add wave -noupdate -color Violet -radix hexadecimal {/cpu_tb/RAM/DATA_MEM[1]}
add wave -noupdate -color Violet -radix hexadecimal {/cpu_tb/RAM/DATA_MEM[0]}
add wave -noupdate -divider {Front End}
add wave -noupdate -label PC /cpu_tb/CPU/FRONTEND/IFQ/pc_out
add wave -noupdate -label {INSTRUCTION QUEUE} /cpu_tb/CPU/FRONTEND/IFQ/BUFF/BUFF_DAT
add wave -noupdate -color Orange -label {DISPATCH OPERAND 1} /cpu_tb/CPU/FRONTEND/DPCH_UNIT/queue_op1_data
add wave -noupdate -color Orange -label {DISPATCH TAG 1} /cpu_tb/CPU/FRONTEND/DPCH_UNIT/queue_op1_tag
add wave -noupdate -color Orange -label {DISPATCH OPERAND 1 VALID} /cpu_tb/CPU/FRONTEND/DPCH_UNIT/queue_op1_data_valid
add wave -noupdate -color Orchid -label {DISPATCH OPERAND 2} /cpu_tb/CPU/FRONTEND/DPCH_UNIT/queue_op2_data
add wave -noupdate -color Orchid -label {DISPATCH TAG 2} /cpu_tb/CPU/FRONTEND/DPCH_UNIT/queue_op2_tag
add wave -noupdate -color Orchid -label {DISPACH OPERAND 2 VALID} /cpu_tb/CPU/FRONTEND/DPCH_UNIT/queue_op2_data_valid
add wave -noupdate -color {Light Steel Blue} -label {DISPATCH DESTINATION TAG} /cpu_tb/CPU/FRONTEND/DPCH_UNIT/queue_rd_tag
add wave -noupdate -color {Light Steel Blue} -label {DISPATCH DESTINATION TAG VALID} /cpu_tb/CPU/FRONTEND/DPCH_UNIT/queue_rd_tag_valid
add wave -noupdate -label {ALU QUEUE ENABLE} /cpu_tb/CPU/FRONTEND/DPCH_UNIT/alu_en
add wave -noupdate -label {AGU QUEUE ENABLE} /cpu_tb/CPU/FRONTEND/DPCH_UNIT/agu_en
add wave -noupdate -label {MUL QUEUE ENABLE} /cpu_tb/CPU/FRONTEND/DPCH_UNIT/mul_en
add wave -noupdate -label {DIV QUEUE ENABLE} /cpu_tb/CPU/FRONTEND/DPCH_UNIT/div_en
add wave -noupdate -label {DISPATCH STATUS} /cpu_tb/CPU/FRONTEND/DPCH_UNIT/STALLER/state
add wave -noupdate -divider {Back End}
add wave -noupdate -color Turquoise -label {CDB QUEUE POSTING} /cpu_tb/cdb_queue_type
add wave -noupdate -color Thistle -label {ALU BRANCH OPERATION} /cpu_tb/CPU/BACKEND/ISSUE/int_branch
add wave -noupdate -color Thistle -label {ALU BRANCH TAKEN} /cpu_tb/CPU/BACKEND/ISSUE/int_branch_taken
add wave -noupdate -color Thistle -label {ALU RESULT} /cpu_tb/CPU/BACKEND/ISSUE/int_result
add wave -noupdate -color {Indian Red} -label {MULT RESULT} /cpu_tb/CPU/BACKEND/ISSUE/mult_result
add wave -noupdate -color Gold -label {DIV RESULT} /cpu_tb/CPU/BACKEND/ISSUE/div_result
add wave -noupdate -color Sienna -label {AGU ADDRESS} /cpu_tb/CPU/BACKEND/AGU_QUEUE/ex_address
add wave -noupdate -color Sienna -label {MEMORY DATA READ} /cpu_tb/CPU/BACKEND/ISSUE/load_data
add wave -noupdate -label {LRU ARBRITRATION BIT} /cpu_tb/CPU/BACKEND/ISSUE/lru_bit
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5258230 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 492
configure wave -valuecolwidth 117
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
WaveRestoreZoom {0 ps} {302740 ps}
