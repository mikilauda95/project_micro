vcom "000.log.vhd"
vcom "001.globals.vhd"
vcom *.vhd

vsim work.tb_dlx(test)


add wave -position insertpoint sim:/tb_dlx/DLX_0/*
add wave -position insertpoint sim:/tb_dlx/DRAM_0/*
add wave -position insertpoint sim:/tb_dlx/IRAM_0/*
add wave -position insertpoint sim:/tb_dlx/DLX_0/datapath_1/register_file_0/*
add wave -position insertpoint sim:/tb_dlx/DLX_0/datapath_1/*

run 250 ns
