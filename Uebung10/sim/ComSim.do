vlib work

vcom ../src/SimpleBus-Bhv-ea.vhd -pslfile ../src/vunit.psl

vsim -novopt SimpleBus

add wave -position end  sim:/simplebus/clk
add wave -position end  sim:/simplebus/request
add wave -position end  sim:/simplebus/grant
add wave -position end  sim:/simplebus/data_valid
add wave -position end  sim:/simplebus/done
add wave -position end  sim:/simplebus/aborting

run 500 ns