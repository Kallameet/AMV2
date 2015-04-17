vlib work
vcom -87 -coverAll ../src/vhdl/prol16_pack.vhd
vcom -87 -coverAll ../src/vhdl/reg_file.vhd
vcom -87 -coverAll ../src/vhdl/datapath.vhd
vcom -87 -coverAll ../src/vhdl/control.vhd
vcom -87 -coverAll ../src/vhdl/alu.vhd
vcom -93 -coverAll ../src/vhdl/memory.vhd
vcom -87 -coverAll ../src/vhdl/cpu.vhd
vcom -87 -coverAll ../src/vhdl/cpu_tb.vhd

vsim -gfile_base_g="regressiontest" -novopt -coverage cpu_tb
run 200 us