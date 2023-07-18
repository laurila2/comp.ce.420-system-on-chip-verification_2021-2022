// ----------------------------------------------------------------------------
// test_base.svh
// ----------------------------------------------------------------------------
// Instantiates the environment and runs a basic example sequence
// ----------------------------------------------------------------------------

class test_base extends uvm_test;
    `uvm_component_utils(test_base)
    
    // environment handle
    env env_h;
    basic_sequence seq_h;

    // configuration wrapper for DUT interface
    axi_dut_config axi_dut_cfg;
    gpio_dut_config gpio_dut_cfg;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
            
        // create environment
        env_h = env::type_id::create("env_h", this);
    
        // create DUT configuration wrapper - no need for factory here
        axi_dut_cfg = new();
        gpio_dut_cfg = new();
    
        // attach the virtual interfaces to dut configuration
        if(!uvm_config_db #(virtual axi_if)::get( this, "",
                            "axi_vi", axi_dut_cfg.axi_vi))
        `uvm_fatal("NOVIF", "No virtual AXI interface set");
        if(!uvm_config_db #(virtual gpio_if)::get( this, "",
                            "gpio_vi", gpio_dut_cfg.gpio_vi))
        `uvm_fatal("NOVIF", "No virtual GPIO interface set");
        
        // share the dut configuration
        uvm_config_db #(axi_dut_config)::set(this, "*", 
                        "axi_dut_configuration", axi_dut_cfg);
        // share the dut configuration
        uvm_config_db #(gpio_dut_config)::set(this, "*", 
                        "gpio_dut_configuration", gpio_dut_cfg);

    endfunction: build_phase
    
    task run_phase(uvm_phase phase);
    
        // raise objection to notify that the testing isn't done yet
        phase.raise_objection(this);

        // create a sequence
        seq_h = basic_sequence::type_id::create("seq_h");

        // start the sequencer
        seq_h.start( env_h.axi_agent_h.seqr_h );

        // ready to stop
        phase.drop_objection(this);

    endtask: run_phase
    
endclass: test_base
