
UVM_HOME          ?= c:/cygwin/home/redelman/Release/uvm-2.0.1
UVM_REGISTER_HOME ?= ../../..

PLATFORM     ?= win32

ifeq ($(PLATFORM),win32)
	WINPLILIB    ?= -L$(MTI_HOME)/$(PLATFORM) -lmtipli
	GCC          ?= $(MTI_HOME)/gcc-4.2.1-mingw32/bin/gcc.exe
	COMPILE_OPTS ?= -m32
	DLL          ?= dll
endif

ifeq ($(PLATFORM),linux)
	WINPLILIB    ?=
	GCC          ?= $(MTI_HOME)/gcc-4.1.2-linux/bin/gcc
	COMPILE_OPTS ?= -m32
	DLL          ?= so
endif

ifeq ($(PLATFORM),linux_x86_64)
	WINPLILIB    ?=
	GCC          ?= $(MTI_HOME)/gcc-4.1.2-linux_x86_64/bin/gcc
	COMPILE_OPTS ?= -m64
	DLL          ?= so
endif

xall:
	rm -rf work
	vlib work

	# -----------------------------------
	# Compile the UVM.
	# -----------------------------------
	vlog +incdir+$(UVM_HOME)/src \
	  $(UVM_HOME)/src/uvm_pkg.sv

	# -----------------------------------
	# Compile the UVM Register Package.
	# -----------------------------------
	vlog +incdir+$(UVM_HOME)/src+$(UVM_REGISTER_HOME)/src \
	  +define+BACKDOOR_DPI \
	  $(UVM_REGISTER_HOME)/src/uvm_register_pkg.sv

	# -----------------------------------
	# Compile the register definitions, 
	# the register file definitions, and the
	# register map definitions - this is the system map.
	# -----------------------------------
	vlog dut_ABC_rf_pkg.sv dut_XYZ_rf_pkg.sv system_map_pkg.sv

	# -----------------------------------
	# Compile the "test"
	# -----------------------------------
	vlog test.sv

	# -----------------------------------
	# Compile the DUTs
	# -----------------------------------
	# Note: +acc - otherwise the PLI
	#  does not have visibility into the HW.
	vlog +acc=rmb dut_ABC.sv dut_XYZ.sv

	# -----------------------------------
	# Compile the top 
	# -----------------------------------
	vlog t.sv

	# -----------------------------------
	# Simulate
	# -----------------------------------
	vsim -sv_lib $(UVM_REGISTER_HOME)/lib/backdoor-$(PLATFORM) -c -do "run -all; quit -f" top

backdoor:
	# -----------------------------------
	# Compile the BACKDOOR PLI code.
	# -----------------------------------
	$(GCC) -fPIC -shared -o $(UVM_REGISTER_HOME)/lib/backdoor-$(PLATFORM).$(DLL) \
	  $(COMPILE_OPTS) \
	  -I$(MTI_HOME)/include \
	  $(UVM_REGISTER_HOME)/src/uvm_register_dpi.c \
	  $(WINPLILIB)

print:
	enscript -2RG --color -T 4 -Esystemverilog \
	-fCourier7 -o x.ps \
	  `pwd`/*.sv

clean: .FORCE
	rm -rf work
	rm -f transcript
	rm -f backdoor*.dll
	rm -f backdoor*.so
	rm -f vsim.wlf

.FORCE:

