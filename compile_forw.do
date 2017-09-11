vcom "a.b.a.log.vhd"
vcom "000-globals.vhd"
vcom *.vhd

vsim work.forwarder

force clk 1 50, 0 100 -repeat 100
force -freeze sim:/forwarder/Regout 32'hFFFFFFF 0
add wave -position insertpoint sim:/forwarder/*
run 10 us
