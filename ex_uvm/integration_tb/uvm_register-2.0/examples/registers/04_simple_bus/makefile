
UVM_HOME          ?= ../../../../uvm
UVM_REGISTER_HOME ?= ../../..

all:
	rm -rf work
	vlib work
	vlog  \
		+incdir+$(UVM_HOME)/src \
		$(UVM_HOME)/src/uvm_pkg.sv \
		+incdir+$(UVM_REGISTER_HOME)/src \
		$(UVM_REGISTER_HOME)/src/uvm_register_pkg.sv \
	  regdef.sv \
	  simple_bus.sv \
	  dut.sv \
	  t.sv \

	vsim +UVM_TESTNAME=default_test -do "do wave.do; run -all; quit -f" -c top

gui: all
	vsim -gui +UVM_TESTNAME=default_test -do vsim.do -suppress 3829 top

print:
	enscript -2RG --color -T 4 -Esystemverilog \
	-fCourier7 -o x.ps \
	  `pwd`/*.sv

clean:
	rm -rf work
	rm -f x.ps x.pdf
	rm -f transcript
	rm -f vsim.wlf
  
