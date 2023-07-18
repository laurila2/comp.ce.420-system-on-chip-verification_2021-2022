add wave -position end  sim:/adder/operand_a_in
add wave -position end  sim:/adder/operand_b_in
add wave -position end  sim:/adder/result_out
add wave -position end  sim:/adder/carry_out

force -freeze sim:/adder/operand_a_in 8'h00 0
force -freeze sim:/adder/operand_b_in 8'h00 0
run
force -freeze sim:/adder/operand_a_in 8'h01 0
force -freeze sim:/adder/operand_b_in 8'h01 0
run
force -freeze sim:/adder/operand_a_in 8'h02 0
force -freeze sim:/adder/operand_b_in 8'h02 0
run
force -freeze sim:/adder/operand_a_in 8'h12 0
force -freeze sim:/adder/operand_b_in 8'h84 0
run
force -freeze sim:/adder/operand_a_in 8'hFF 0
force -freeze sim:/adder/operand_b_in 8'hFF 0
run
force -freeze sim:/adder/operand_a_in 8'hFF 0
force -freeze sim:/adder/operand_b_in 8'h00 0
run
force -freeze sim:/adder/operand_a_in 8'hA3 0
force -freeze sim:/adder/operand_b_in 8'h7F 0
run
