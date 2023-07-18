#Makefile for FIFO compilation/simulation

+UVM_VERBOSITY ?= UVM_MEDIUM
+UVM_TESTNAME ?= random_test
UVM_FLAGS = -sv_seed random

DUT=../rtl/decrypter.sv ../rtl/decrypter_axi_wrapper.sv
DUT_IF=../axi_agent/axi_if.sv ../gpio_agent/gpio_if.sv
AGENTS=../axi_agent/axi_agent_pkg.sv ../gpio_agent/gpio_agent_pkg.sv
ENV=../env/decrypter_axi_tb_env_pkg.sv
PKG=$(AGENTS) $(ENV) ../tests/decrypter_axi_tb_pkg.sv
TOP=../decrypter_axi_tb_top.sv

ifneq "$(strip $(+UVM_VERBOSITY))" ""
  UVM_FLAGS += +UVM_VERBOSITY=$(+UVM_VERBOSITY)
endif
ifneq "$(strip $(+UVM_TESTNAME))" ""
  UVM_FLAGS += +UVM_TESTNAME=$(+UVM_TESTNAME)
endif

normal: work compile run
gui: work compile run_gui

run_gui:
	vsim -do uvm_gui.do -voptargs=+acc -coverage -suppress 3829 $(UVM_FLAGS) decrypter_axi_tb_top

run: 
	vsim -do uvm_vsim.do -c -coverage -suppress 3829 $(UVM_FLAGS) decrypter_axi_tb_top

compile: clean work
#	vlog +cover=s -mfcu $(DUT) $(DUT_IF) $(PKG) $(TOP)
	vlog -mfcu $(DUT) $(DUT_IF) $(PKG) $(TOP)

work: 
	vlib decrypter_axi_tb_lib
	vmap work decrypter_axi_tb_lib
	
clean:
	rm -rf  *.tmp  *.log  log transcript *.wlf vsim.fcdb *.vstf

coverage:
	vcover report -details vsim.ucdb > report.txt

html: 
	vcover report -details -html -htmldir cov_report vsim.ucdb
