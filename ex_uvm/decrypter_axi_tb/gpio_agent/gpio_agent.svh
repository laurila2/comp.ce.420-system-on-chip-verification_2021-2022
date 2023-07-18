// ----------------------------------------------------------------------------
// gpio_agent.svh
// ----------------------------------------------------------------------------
// UVM agent class
// ----------------------------------------------------------------------------

class gpio_agent extends uvm_agent;
    `uvm_component_utils(gpio_agent)
        
    // component handles - passive agent
    gpio_monitor mon_h;
    
    // analysis port handle
    uvm_analysis_port #(gpio_transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        
        // create components
        mon_h  = gpio_monitor::type_id::create("mon_h", this);

        // create analysis port
        ap = new("ap", this);
        
        // debug prints
        `uvm_info("gpio_agent","Created gpio_agent",UVM_HIGH)
    
    endfunction: build_phase
    
    function void connect_phase(uvm_phase phase);
        
        // Connect monitor's analysis port
        mon_h.ap.connect(ap);
        
    endfunction: connect_phase
    
endclass: gpio_agent
