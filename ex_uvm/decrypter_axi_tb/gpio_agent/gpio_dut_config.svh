// ----------------------------------------------------------------------------
// gpio_dut_config.svh
// ----------------------------------------------------------------------------
// Interface wrapper for the DUT interface
// places dut_if inside an uvm_object to be included 
// in the UVM configuration table
// ----------------------------------------------------------------------------

class gpio_dut_config extends uvm_object;
    `uvm_object_utils(gpio_dut_config)
    
    virtual gpio_if gpio_vi; 

    function new(string name = "");
        super.new(name);
    endfunction: new
    
endclass: gpio_dut_config
