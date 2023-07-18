#Makefile for FIFO UVM testbench compilation/simulation

+UVM_VERBOSITY ?= UVM_HIGH
+UVM_TESTNAME ?= 
UVM_FLAGS = 

DUT ?= ../rtl/fifo.vhd
DUT_IF=../fifo_tb_pkg/dut_if.sv
PKG=../fifo_tb_pkg/fifo_tb_pkg.sv
TOP=../fifo_tb_top.sv

ifneq "$(strip $(+UVM_VERBOSITY))" ""
  UVM_FLAGS += +UVM_VERBOSITY=$(+UVM_VERBOSITY)
endif
ifneq "$(strip $(+UVM_TESTNAME))" ""
  UVM_FLAGS += +UVM_TESTNAME=$(+UVM_TESTNAME)
endif

normal: compile run
gui: compile run-gui

run-gui:
	vsim -do vsim_gui.do -coverage -suppress 3829 $(UVM_FLAGS) fifo_tb_top
run:
	vsim -do vsim.do -c -coverage -suppress 3829 $(UVM_FLAGS) fifo_tb_top

compile: work
	vcom $(DUT)
	vlog +cover=s $(DUT_IF) $(PKG) $(TOP)

work:
	vlib fifo_tb_lib
	vmap work fifo_tb_lib

clean:
	rm -rf  *.tmp  *.log  log transcript *.wlf vsim.fcdb vsim.ucdb *.vstf fifo_tb_lib

coverage:
	vcover report -details vsim.ucdb > report.txt

html:
	vcover report -details -html -htmldir cov_report vsim.ucdb
