vlib work

vcom -87 ../src/vhdl/prol16_pack.vhd
vcom -87 ../src/vhdl/reg_file.vhd
vcom -87 ../src/vhdl/alu.vhd -pslfile ../src/vhdl/alu_v.psl
vcom -87 ../src/vhdl/datapath.vhd
vcom -87 ../src/vhdl/control.vhd -pslfile ../src/vhdl/control_v.psl
vcom -93 ../src/vhdl/memory.vhd
vcom -87 ../src/vhdl/cpu.vhd
vcom -87 ../src/vhdl/cpu_tb.vhd

vsim -novopt cpu_tb
run -all