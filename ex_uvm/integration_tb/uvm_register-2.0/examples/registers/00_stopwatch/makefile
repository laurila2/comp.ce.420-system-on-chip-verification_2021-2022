#
# To pick a different UVM, in a csh do:
#   setenv UVM_HOME <my_uvm_place>/uvm
#
UVM_HOME       ?= ../../../../uvm
UVM_REGISTER_HOME ?= ../../../

# To trace function calls use
#   vlog -mti_trace_vlog_calls
# AND
#   issue the SetVlogTrace command in vsim 
#     SetVlogTrace 1
# Comment out the lines below to turn on
#  *lots* of tracing
# VLOG_TRACE = -mti_trace_vlog_calls
# VSIM_TRACE = SetVlogTrace 1;

NCV_COMPAT   ?= +define+NCV
VLOG_OPTIONS ?= $(NCV_COMPAT)

all:
	rm -rf work
	vlib work

	# Compile the UVM
	vlog $(VLOG_TRACE) \
	  +incdir+$(UVM_HOME)/src \
	  $(UVM_HOME)/src/uvm_pkg.sv 

	# Compile the UVM_UTILs
	#  Note: The vlog option
	#    "-Epretty outputfile.sv" 
	#  can be used for debug. 
	#  It expands macros
	vlog $(VLOG_OPTIONS) \
	  -Edebug outputfile.sv $(VLOG_TRACE) \
	  +incdir+$(UVM_REGISTER_HOME)/src+$(UVM_HOME)/src \
	  $(UVM_REGISTER_HOME)/src/uvm_register_pkg.sv 
	
	# Compile the Register and Address map definitions
	vlog $(VLOG_OPTIONS) \
	  +incdir+$(UVM_REGISTER_HOME)/src \
	  $(VLOG_TRACE) auto/stopwatch_register_pkg.sv
	  

	# Compile the test
	vlog $(VLOG_OPTIONS) \
	  $(VLOG_TRACE) +incdir+$(UVM_HOME)/src t.sv

	# Compile the Hardware
	vlog dut/stopwatch_rtl.sv
	vlog dut/stopwatch_rtl_wrapper.sv

	# Simulate
	vsim -c top -do "$(VSIM_TRACE) run -all; quit -f"

ius:
	Irun -messages \
	  +incdir+$(UVM_HOME)/src \
	  +incdir+$(UVM_REGISTER_HOME)/src \
	  $(UVM_HOME)/src/uvm_pkg.sv  \
	  $(UVM_REGISTER_HOME)/src/uvm_register_pkg.sv  \
	  auto/stopwatch_register_pkg.sv \
	  t.sv \
	  dut/stopwatch_rtl.sv \
	  dut/stopwatch_rtl_wrapper.sv

clean:
	rm -rf work
	rm -f code.sv
	rm -f transcript vsim.wlf x.ps x.pdf
	rm -f outputfile

print:
	enscript -2RG --color \
	  --header `pwd` \
	  -o x.ps -Esystemverilog -fCourier7 \
		     t.sv \
		auto/stopwatch_register_pkg.sv \
		 dut/stopwatch_rtl.sv \
		 dut/stopwatch_rtl_wrapper.sv

