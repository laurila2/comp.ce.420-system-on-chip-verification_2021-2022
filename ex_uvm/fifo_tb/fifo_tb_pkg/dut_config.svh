// ----------------------------------------------------------------------------
// dut_config.svh
// ----------------------------------------------------------------------------
// Configuration object for the DUT
// Includes only an interface wrapper for the DUT interface
// ----------------------------------------------------------------------------

class dut_config extends uvm_object;
    `uvm_object_utils(dut_config)

    virtual dut_if dut_vi; //_vi = virtual interface

    // Add other configuration here, if needed

    function new(string name = "");
        super.new(name);
    endfunction: new

endclass: dut_config
