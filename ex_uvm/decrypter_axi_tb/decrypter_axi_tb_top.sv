// ----------------------------------------------------------------------------
// decrypter_axi_tb_top.sv
// ----------------------------------------------------------------------------
// Top level
// - Connects the DUT 
// - Generates the clk 
// - Starts the test
// ----------------------------------------------------------------------------
`include "uvm_macros.svh"

module decrypter_axi_tb_top;
    import uvm_pkg::*;
    import decrypter_axi_tb_pkg::*;
    
    bit     clk, rst_n;
    axi_if  axi_interface (clk, rst_n); // AXI interface for DUT
    gpio_if gpio_interface ();        // GPIO interface for DUT
    
    initial begin : init

        clk = 0;
        
        // share the pointers to dut interfaces via config db
        uvm_config_db #(virtual axi_if)::set(null,
                                   "uvm_test_top",
                                         "axi_vi",
                                    axi_interface);
                                    
        uvm_config_db #(virtual gpio_if)::set(null, 
                                   "uvm_test_top",
                                          "gpio_vi",
                                     gpio_interface);
        // start the test
        run_test ();
        
    end : init
    
    initial begin: reset_generator
        rst_n = 0;
        #2 rst_n = 1;
    end
    
    // create clock, 2ns cycle
    always begin : clock_generator
        #1 clk =! clk;
    end : clock_generator

    // instantiate the fifo
    \decrypter_axi_tb_lib.decrypter_axi_wrapper DUT (
        .clk                    (axi_interface.clk),
        .rst_n                  (axi_interface.rst_n),
        .waddr_channel          (axi_interface.waddr_channel),
        .wdata_channel          (axi_interface.wdata_channel),
        .wresp_channel          (axi_interface.wresp_channel),
        .valid_from_dec_out     (gpio_interface.valid),
        .decrypted_from_dec_out (gpio_interface.decrypted)
    );
    
endmodule: decrypter_axi_tb_top
