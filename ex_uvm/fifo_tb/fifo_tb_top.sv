// ----------------------------------------------------------------------------
// fifo_tb_top.sv
// ----------------------------------------------------------------------------
// Top level
// - Connects the DUT
// - Generates the clk
// - Starts the test
// ----------------------------------------------------------------------------

`include "uvm_macros.svh"

module fifo_tb_top;
    import uvm_pkg::*;
    import fifo_tb_pkg::*;

    bit         clk;
    dut_if      dut_interface (clk);  // Interface for DUT

    initial begin : init
        clk = 0;
        dut_interface.rst_n = 0;
        dut_interface.we_out = 0;
        dut_interface.re_out = 0;
        dut_interface.data_to_DUT = 0;
        #2 dut_interface.rst_n = 1;
    end: init

    initial begin : init_uvm
        // share the dut interface via config db
        uvm_config_db #(virtual dut_if)::set(null, "uvm_test_top",
                                         "dut_vi", dut_interface);  

        // start the test
        run_test ("test_base");

    end : init_uvm

    // create clock, 2ns cycle
    always begin : clock_generator
        #1 clk =! clk;
    end : clock_generator

    // instantiate the fifo and connect it to the interface
    \fifo_tb_lib.fifo(behavioral) DUT (
        .clk       (dut_interface.clk),
        .rst_n     (dut_interface.rst_n),
        .data_in   (dut_interface.data_to_DUT),
        .we_in     (dut_interface.we_out),
        .full_out  (dut_interface.full_in),
        .one_p_out (dut_interface.one_p_in),
        .re_in     (dut_interface.re_out),
        .data_out  (dut_interface.data_from_DUT),
        .empty_out (dut_interface.empty_in),
        .one_d_out (dut_interface.one_d_in)
    );

endmodule: fifo_tb_top
