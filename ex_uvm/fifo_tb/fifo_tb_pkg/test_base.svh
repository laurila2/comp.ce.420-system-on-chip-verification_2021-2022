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
    dut_config dut_cfg;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);

        // create environment
        env_h = env::type_id::create("env_h", this);

        // create DUT configuration wrapper - no need for factory here
        dut_cfg = new();

        // attach the virtual interface to dut configuration
        if(!uvm_config_db #(virtual dut_if)::get( this, "",
                                   "dut_vi", dut_cfg.dut_vi))
        `uvm_fatal("NOVIF", "No virtual interface set");

        // share the dut configuration
        uvm_config_db #(dut_config)::set(this, "*",
                        "dut_configuration", dut_cfg);

    endfunction: build_phase

    task run_phase(uvm_phase phase);

        // raise objection to notify that the testing isn't done yet
        phase.raise_objection(this);

        // create a sequence
        seq_h = basic_sequence::type_id::create("seq_h");

        // start the sequencer
        seq_h.start( env_h.agent_h.seqr_h );

        // wait 1 cycle before ending the simulation
        #2;

        // ready to stop
        phase.drop_objection(this);

    endtask: run_phase

endclass: test_base
