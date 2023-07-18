// ----------------------------------------------------------------------------
// axi_agent.svh
// ----------------------------------------------------------------------------
// UVM agent class
// ----------------------------------------------------------------------------

class axi_agent extends uvm_agent;
    `uvm_component_utils(axi_agent)
        
    // component handles
    sequencer   seqr_h;
    axi_driver  drv_h;
    axi_monitor mon_h;
    
    // analysis port handle
    uvm_analysis_port #(axi_transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        
        // create components
        seqr_h =   sequencer::type_id::create("seqr_h",this);
        drv_h  =  axi_driver::type_id::create("drv_h", this);
        mon_h  = axi_monitor::type_id::create("mon_h", this);

        // create analysis port
        ap = new("ap", this);
        
        // debug prints
        `uvm_info("axi_agent","Created axi_agent",UVM_HIGH)
    
    endfunction: build_phase
    
    function void connect_phase(uvm_phase phase);
    
        // connect driver's port (input) to the sequencer's export (output)
        drv_h.seq_item_port.connect(seqr_h.seq_item_export);
    
        // Connect monitor's analysis port
        mon_h.ap.connect(ap);
        
    endfunction: connect_phase
    
endclass: axi_agent
