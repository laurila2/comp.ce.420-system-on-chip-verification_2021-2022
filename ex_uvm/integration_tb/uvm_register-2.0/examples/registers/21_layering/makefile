UVM_HOME          ?= ../../../../uvm
UVM_REGISTER_HOME ?= ../../../

all:
	rm -rf work
	vlib work

	# Compile the UVM
	vlog $(VLOG_TRACE) \
	  +incdir+$(UVM_HOME)/src \
	  $(UVM_HOME)/src/uvm_pkg.sv 

	# Compile the UVM_REGISTER package
	vlog $(VLOG_TRACE) \
	  +define+NCV \
	  +incdir+$(UVM_REGISTER_HOME)/src+$(UVM_HOME)/src \
	  $(UVM_REGISTER_HOME)/src/uvm_register_pkg.sv 
	
	# Compile the registers
	vlog $(VLOG_TRACE) \
	  +incdir+$(UVM_REGISTER_HOME)/src+$(UVM_HOME)/src \
	  regdef.sv

	# Compile the testbench.
	vlog $(VLOG_TRACE) \
	  +incdir+$(UVM_REGISTER_HOME)/src+$(UVM_HOME)/src \
	  t.sv

	# Simulate
	vsim -c top -do "$(VSIM_TRACE) run -all; quit -f"

clean:
	rm -rf work
	rm -f code.sv
	rm -f transcript vsim.wlf x.ps x.pdf
	rm -f outputfile

print:
	enscript -2RG --color \
	  --header `pwd` \
	  -o x.ps -Esystemverilog -fCourier7 \
		     t.sv regdef.sv

