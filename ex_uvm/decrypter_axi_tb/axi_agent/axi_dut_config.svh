// ----------------------------------------------------------------------------
// axi_dut_config.svh
// ----------------------------------------------------------------------------
// Interface wrapper for the DUT interface
// places dut_if inside an uvm_object to be included 
// in the UVM configuration table
// ----------------------------------------------------------------------------

class axi_dut_config extends uvm_object;
    `uvm_object_utils(axi_dut_config)
    
    virtual axi_if  axi_vi;
	

    function new(string name = "");
        super.new(name);
    endfunction: new
    
endclass: axi_dut_config
