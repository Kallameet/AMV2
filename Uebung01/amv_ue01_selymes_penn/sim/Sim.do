vsim -novopt tbWishboneBFM
add wave -position end  sim:/tbwishbonebfm/busIn
add wave -position end  sim:/tbwishbonebfm/busOut
add wave -position end  sim:/tbwishbonebfm/testInput1
add wave -position end  sim:/tbwishbonebfm/testInput2
log -r *
run -all