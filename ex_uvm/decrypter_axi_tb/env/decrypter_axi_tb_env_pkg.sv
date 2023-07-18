// ----------------------------------------------------------------------------
// decrypter_axi_tb_env_pkg.sv
// ----------------------------------------------------------------------------
// Package file for UVM testbench for AXI4-Lite decrypter 
// - Environment
//
// Mentor Graphics UVM guidelines (UVM Cookbook p. 570):
// - `include classes in a package file
// - No `includes in class definition files
// ----------------------------------------------------------------------------

package decrypter_axi_tb_env_pkg;

    // UVM requirements
    `include "uvm_macros.svh"
    import uvm_pkg::*;
	
    // Import agents
    import gpio_agent_pkg::*;
    import axi_agent_pkg::*;

    // Components
    `include "coverage.svh"
    `include "scoreboard.svh"

    // Environment
    `include "env.svh"


endpackage: decrypter_axi_tb_env_pkg
