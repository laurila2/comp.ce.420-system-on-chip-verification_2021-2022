// ----------------------------------------------------------------------------
// decrypter_axi_tb_pkg.sv
// ----------------------------------------------------------------------------
// Package file for UVM testbench for AXI4-Lite decrypter 
// - Tests and sequences
//
// Mentor Graphics UVM guidelines (UVM Cookbook p. 570):
// - `include classes in a package file
// - No `includes in class definition files
// ----------------------------------------------------------------------------

package decrypter_axi_tb_pkg;

    // UVM requirements
    `include "uvm_macros.svh"
    import uvm_pkg::*;
    
    // define macros for AXI addresses
    `include "../rtl/axi_defines.svh"

    // Import agents and env
    import gpio_agent_pkg::*;
    import axi_agent_pkg::*;
    import decrypter_axi_tb_env_pkg::*;
    
    // Sequences
    `include "sequence.svh"
    `include "random_sequence.svh"
    
    // Tests
    `include "test_base.svh"
    `include "random_test.svh"

endpackage: decrypter_axi_tb_pkg
