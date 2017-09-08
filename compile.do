
vcom "a.b.a.log.vhd"
vcom "000-globals.vhd"
vcom *.vhd

vsim work.tb_dlx(test)

add wave -position insertpoint sim:/tb_dlx/DLX_0/datapath_1/*

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
add wave -position insertpoint  \
sim:/tb_dlx/DLX_0/datapath_1/register_file_0/CLK \
sim:/tb_dlx/DLX_0/datapath_1/register_file_0/RESET \
sim:/tb_dlx/DLX_0/datapath_1/register_file_0/ENABLE \
sim:/tb_dlx/DLX_0/datapath_1/register_file_0/RD1 \
sim:/tb_dlx/DLX_0/datapath_1/register_file_0/RD2 \
sim:/tb_dlx/DLX_0/datapath_1/register_file_0/WR \
sim:/tb_dlx/DLX_0/datapath_1/register_file_0/ADD_WR \
sim:/tb_dlx/DLX_0/datapath_1/register_file_0/ADD_RD1 \
sim:/tb_dlx/DLX_0/datapath_1/register_file_0/ADD_RD2 \
sim:/tb_dlx/DLX_0/datapath_1/register_file_0/DATAIN \
sim:/tb_dlx/DLX_0/datapath_1/register_file_0/OUT1 \
sim:/tb_dlx/DLX_0/datapath_1/register_file_0/OUT2 \
sim:/tb_dlx/DLX_0/datapath_1/register_file_0/REGISTERS
add wave -position insertpoint  \
sim:/tb_dlx/DLX_0/datapath_1/JUMP_BRANCH
add wave -position insertpoint  \
sim:/tb_dlx/DLX_0/datapath_1/MUXJ_SEL
add wave -position insertpoint  \
sim:/tb_dlx/DLX_0/datapath_1/imm_j



run 200 ns
