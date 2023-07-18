add wave -position end \
/fifo_tb_top/dut_interface/clk \
/fifo_tb_top/dut_interface/rst_n \
/fifo_tb_top/dut_interface/data_to_DUT \
/fifo_tb_top/dut_interface/we_out \
/fifo_tb_top/dut_interface/re_out \
/fifo_tb_top/dut_interface/data_from_DUT \
/fifo_tb_top/dut_interface/full_in \
/fifo_tb_top/dut_interface/one_p_in \
/fifo_tb_top/dut_interface/empty_in \
/fifo_tb_top/dut_interface/one_d_in

do vsim.do
