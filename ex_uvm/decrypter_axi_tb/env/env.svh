// ----------------------------------------------------------------------------
// env.svh
// ----------------------------------------------------------------------------
// UVM environment class
// ----------------------------------------------------------------------------

class env extends uvm_env;
    `uvm_component_utils(env)
    
    // Component handles
    axi_agent          axi_agent_h; 
    gpio_agent         gpio_agent_h; 
    coverage_collector cov_h;
    scoreboard         scb_h;
    
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        
        // create components
        axi_agent_h  = axi_agent         ::type_id::create("axi_agent_h" ,this);
        gpio_agent_h = gpio_agent        ::type_id::create("gpio_agent_h",this);
        cov_h        = coverage_collector::type_id::create("cov_h"       ,this);
        scb_h        = scoreboard        ::type_id::create("scb_h"       ,this);

        // debug prints
        `uvm_info("env","Created environment",UVM_HIGH)                
        
    endfunction: build_phase
    function void connect_phase(uvm_phase phase);
        
        // Connect subscribers to agents' analysis port
        axi_agent_h.ap.connect(cov_h.analysis_export);
        axi_agent_h.ap.connect(scb_h.axi_analysis_export);
        gpio_agent_h.ap.connect(scb_h.gpio_analysis_export);
    
    endfunction: connect_phase
   
endclass: env
