// ----------------------------------------------------------------------------
// fifo_tb_pkg.sv
// ----------------------------------------------------------------------------
// Package file for UVM testbench for FIFO
// - Transaction and configuration wrapper classes
// - Environment
// - Tests and sequences
// ----------------------------------------------------------------------------
// Mentor Graphics UVM guidelines (UVM Cookbook p. 570):
// - `include classes in a package file
// - No `includes in class definition files
// ----------------------------------------------------------------------------

package fifo_tb_pkg;

    // UVM requirements
    `include "uvm_macros.svh"
    import uvm_pkg::*;

    // Communication classes
    `include "dut_config.svh"
    `include "transaction.svh"

    // Components
    `include "sequencer.svh"
    `include "driver.svh"
    `include "monitor.svh"

    // Agent and environment
   
    `include "agent.svh"
    `include "coverage.svh"
    `include "scoreboard.svh"
    `include "env.svh"

    // Sequences
    `include "sequence.svh"
    `include "rand_sequence.svh"

    // Tests
    `include "test_base.svh"
    `include "random_test.svh"

endpackage: fifo_tb_pkg
