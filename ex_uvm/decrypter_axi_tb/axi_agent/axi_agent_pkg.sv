// ----------------------------------------------------------------------------
// axi_agent_pkg.sv
// ----------------------------------------------------------------------------
// Package file for UVM testbench for AXI4-Lite decrypter 
// - AXI agent
//
// Mentor Graphics UVM guidelines (UVM Cookbook p. 570):
// - `include classes in a package file
// - No `includes in class definition files
// ----------------------------------------------------------------------------


package axi_agent_pkg;

    // UVM requirements
    `include "uvm_macros.svh"
    import uvm_pkg::*;
	    
    `include "axi_dut_config.svh"
    `include "axi_transaction.svh"
    typedef uvm_sequencer #(axi_transaction) sequencer;
    `include "axi_driver.svh"
    `include "axi_monitor.svh"
    `include "axi_agent.svh"
    
endpackage: axi_agent_pkg
