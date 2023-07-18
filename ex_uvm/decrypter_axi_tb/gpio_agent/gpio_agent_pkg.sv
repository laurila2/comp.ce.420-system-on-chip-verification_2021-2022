// ----------------------------------------------------------------------------
// gpio_agent_pkg.sv
// ----------------------------------------------------------------------------
// Package file for UVM testbench for AXI4-Lite decrypter 
// - GPIO agent
//
// Mentor Graphics UVM guidelines (UVM Cookbook p. 570):
// - `include classes in a package file
// - No `includes in class definition files
// ----------------------------------------------------------------------------

package gpio_agent_pkg;

    // UVM requirements
    `include "uvm_macros.svh"
    import uvm_pkg::*;
    
    `include "gpio_dut_config.svh"
    `include "gpio_transaction.svh"
    `include "gpio_monitor.svh"
    `include "gpio_agent.svh"

endpackage: gpio_agent_pkg
