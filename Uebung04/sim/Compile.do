vlib work

vlog ../src/sv/ifProl16.sv
vlog ../src/sv/pkgProl16.sv
vlog ../src/sv/Prol16Command.sv
vlog ../src/sv/Prol16Opcode.sv +incdir+../src
vlog ../src/sv/Prol16State.sv +incdir+../src
vlog ../src/sv/Prol16Model.sv +incdir+../src
vlog ../src/sv/testProl16Model.sv +incdir+../src
vlog ../src/sv/top.sv +incdir+../src

vcom -87 ../src/vhdl/prol16_pack.vhd
vcom -87 ../src/vhdl/reg_file.vhd
vcom -87 ../src/vhdl/datapath.vhd
vcom -87 ../src/vhdl/control.vhd
vcom -87 ../src/vhdl/alu.vhd
vcom -93 ../src/vhdl/memory.vhd
vcom -87 ../src/vhdl/cpu.vhd
#vcom -87 ../src/vhdl/cpu_tb.vhd