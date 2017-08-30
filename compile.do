rm -r work
vlib work
vcom "a.b.a.log.vhd"
vcom "000-globals.vhd"
vcom *.vhd

vsim work.tb_dlx(test)

add wave -position insertpoint  \
sim:/tb_dlx/DLX_0/datapath_1/n_bit \
sim:/tb_dlx/DLX_0/datapath_1/CW_SIZE \
sim:/tb_dlx/DLX_0/datapath_1/clk \
sim:/tb_dlx/DLX_0/datapath_1/reset \
sim:/tb_dlx/DLX_0/datapath_1/IR_LATCH_EN \
sim:/tb_dlx/DLX_0/datapath_1/NPC_LATCH_EN \
sim:/tb_dlx/DLX_0/datapath_1/RegA_LATCH_EN \
sim:/tb_dlx/DLX_0/datapath_1/RegB_LATCH_EN \
sim:/tb_dlx/DLX_0/datapath_1/RegIMM_LATCH_EN \
sim:/tb_dlx/DLX_0/datapath_1/MUXA_SEL \
sim:/tb_dlx/DLX_0/datapath_1/MUXB_SEL \
sim:/tb_dlx/DLX_0/datapath_1/ALU_OUTREG_EN \
sim:/tb_dlx/DLX_0/datapath_1/EQ_COND \
sim:/tb_dlx/DLX_0/datapath_1/ALU_OPCODE \
sim:/tb_dlx/DLX_0/datapath_1/DRAM_WE \
sim:/tb_dlx/DLX_0/datapath_1/LMD_LATCH_EN \
sim:/tb_dlx/DLX_0/datapath_1/JUMP_EN \
sim:/tb_dlx/DLX_0/datapath_1/PC_LATCH_EN \
sim:/tb_dlx/DLX_0/datapath_1/WB_MUX_SEL \
sim:/tb_dlx/DLX_0/datapath_1/RF_WE \
sim:/tb_dlx/DLX_0/datapath_1/IRAMout \
sim:/tb_dlx/DLX_0/datapath_1/PC_out \
sim:/tb_dlx/DLX_0/datapath_1/ADDPC_out_sig \
sim:/tb_dlx/DLX_0/datapath_1/NPC_out_sig \
sim:/tb_dlx/DLX_0/datapath_1/IRout \
sim:/tb_dlx/DLX_0/datapath_1/MUX_BRANCHES_sig \
sim:/tb_dlx/DLX_0/datapath_1/PC_OUT_sig \
sim:/tb_dlx/DLX_0/datapath_1/reg_file_in \
sim:/tb_dlx/DLX_0/datapath_1/regin1 \
sim:/tb_dlx/DLX_0/datapath_1/reg_mux1 \
sim:/tb_dlx/DLX_0/datapath_1/regin2 \
sim:/tb_dlx/DLX_0/datapath_1/reg_mux2 \
sim:/tb_dlx/DLX_0/datapath_1/imm2 \
sim:/tb_dlx/DLX_0/datapath_1/imm_mux2 \
sim:/tb_dlx/DLX_0/datapath_1/reg_alu_out \
sim:/tb_dlx/DLX_0/datapath_1/ALUout \
sim:/tb_dlx/DLX_0/datapath_1/ALUin1 \
sim:/tb_dlx/DLX_0/datapath_1/ALUin2 \
sim:/tb_dlx/DLX_0/datapath_1/pc_mux_sig \
sim:/tb_dlx/DLX_0/datapath_1/not_comp_sig \
sim:/tb_dlx/DLX_0/datapath_1/comp_sig \
sim:/tb_dlx/DLX_0/datapath_1/branch_out_sig \
sim:/tb_dlx/DLX_0/datapath_1/sign_ext_delay \
sim:/tb_dlx/DLX_0/datapath_1/DRAMout \
sim:/tb_dlx/DLX_0/datapath_1/LMDout
add wave -position insertpoint  \
sim:/tb_dlx/DLX_0/dlx_cu_0/MICROCODE_MEM_SIZE \
sim:/tb_dlx/DLX_0/dlx_cu_0/FUNC_SIZE \
sim:/tb_dlx/DLX_0/dlx_cu_0/OP_CODE_SIZE \
sim:/tb_dlx/DLX_0/dlx_cu_0/IR_SIZE \
sim:/tb_dlx/DLX_0/dlx_cu_0/CW_SIZE \
sim:/tb_dlx/DLX_0/dlx_cu_0/Clk \
sim:/tb_dlx/DLX_0/dlx_cu_0/Rst \
sim:/tb_dlx/DLX_0/dlx_cu_0/IR_IN \
sim:/tb_dlx/DLX_0/dlx_cu_0/IR_LATCH_EN \
sim:/tb_dlx/DLX_0/dlx_cu_0/NPC_LATCH_EN \
sim:/tb_dlx/DLX_0/dlx_cu_0/RegA_LATCH_EN \
sim:/tb_dlx/DLX_0/dlx_cu_0/RegB_LATCH_EN \
sim:/tb_dlx/DLX_0/dlx_cu_0/RegIMM_LATCH_EN \
sim:/tb_dlx/DLX_0/dlx_cu_0/MUXA_SEL \
sim:/tb_dlx/DLX_0/dlx_cu_0/MUXB_SEL \
sim:/tb_dlx/DLX_0/dlx_cu_0/ALU_OUTREG_EN \
sim:/tb_dlx/DLX_0/dlx_cu_0/EQ_COND \
sim:/tb_dlx/DLX_0/dlx_cu_0/ALU_OPCODE \
sim:/tb_dlx/DLX_0/dlx_cu_0/DRAM_WE \
sim:/tb_dlx/DLX_0/dlx_cu_0/LMD_LATCH_EN \
sim:/tb_dlx/DLX_0/dlx_cu_0/JUMP_EN \
sim:/tb_dlx/DLX_0/dlx_cu_0/PC_LATCH_EN \
sim:/tb_dlx/DLX_0/dlx_cu_0/WB_MUX_SEL \
sim:/tb_dlx/DLX_0/dlx_cu_0/RF_WE \
sim:/tb_dlx/DLX_0/dlx_cu_0/cw_mem \
sim:/tb_dlx/DLX_0/dlx_cu_0/IR_opcode \
sim:/tb_dlx/DLX_0/dlx_cu_0/IR_func \
sim:/tb_dlx/DLX_0/dlx_cu_0/cw \
sim:/tb_dlx/DLX_0/dlx_cu_0/cw1 \
sim:/tb_dlx/DLX_0/dlx_cu_0/cw2 \
sim:/tb_dlx/DLX_0/dlx_cu_0/cw3 \
sim:/tb_dlx/DLX_0/dlx_cu_0/cw4 \
sim:/tb_dlx/DLX_0/dlx_cu_0/cw5 \
sim:/tb_dlx/DLX_0/dlx_cu_0/aluOpcode_i \
sim:/tb_dlx/DLX_0/dlx_cu_0/aluOpcode1 \
sim:/tb_dlx/DLX_0/dlx_cu_0/aluOpcode2 \
sim:/tb_dlx/DLX_0/dlx_cu_0/aluOpcode3 \
sim:/tb_dlx/DLX_0/dlx_cu_0/zero_stage_cwnum \
sim:/tb_dlx/DLX_0/dlx_cu_0/first_stage_cwnum \
sim:/tb_dlx/DLX_0/dlx_cu_0/second_stage_cwnum \
sim:/tb_dlx/DLX_0/dlx_cu_0/third_stage_cwnum \
sim:/tb_dlx/DLX_0/dlx_cu_0/OFFSET_CU2 \
sim:/tb_dlx/DLX_0/dlx_cu_0/OFFSET_CU3 \
sim:/tb_dlx/DLX_0/dlx_cu_0/OFFSET_CU4 \
sim:/tb_dlx/DLX_0/dlx_cu_0/OFFSET_CU5
add wave -position insertpoint  \
sim:/tb_dlx/DLX_0/IRAM_0/RAM_DEPTH \
sim:/tb_dlx/DLX_0/IRAM_0/I_SIZE \
sim:/tb_dlx/DLX_0/IRAM_0/Rst \
sim:/tb_dlx/DLX_0/IRAM_0/Addr \
sim:/tb_dlx/DLX_0/IRAM_0/Dout \
sim:/tb_dlx/DLX_0/IRAM_0/IRAM_mem



run 100 ns
