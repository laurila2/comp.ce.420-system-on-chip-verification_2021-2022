// ----------------------------------------------------------------------------
// random_test.svh
// ----------------------------------------------------------------------------
// A random test extending test_base
// ----------------------------------------------------------------------------

class random_test extends test_base;
    `uvm_component_utils(random_test)
    
    // constants for stopping the test based on coverage or time
    const real coverage_goal = 99.9;
    const int  max_time = 100000;
      
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction: build_phase
    
    function void start_of_simulation_phase(uvm_phase phase);
    
        // print the seed value
        `uvm_info("Test", $psprintf("Random seed = %d",
                $get_initial_random_seed()),UVM_MEDIUM)
                      
    endfunction: start_of_simulation_phase
    
    task run_phase(uvm_phase phase);
    
        // raise objection to notify that the testing isn't done yet
        phase.raise_objection(this);

        // create a sequence
        seq_h = random_sequence::type_id::create("seq_h");
        
        // run the sequencer in parallel with stop condition checker
        fork begin : sequencer_thread

            // start the sequencer
            seq_h.start( env_h.axi_agent_h.seqr_h );
    
        end : sequencer_thread
        
        // Thread to monitor the coverage status and stop the test if goal 
        // or time limit reached 
        begin : stop_condition_thread
        
            // wait until coverage requirements met or time limit reached
            @( env_h.cov_h.get_cg_coverage() >= coverage_goal || 
                                       $time >= max_time );

            // stop the sequencer 
            env_h.axi_agent_h.seqr_h.stop_sequences();
            
            // final prints
            `uvm_info("Test", "Stopping sequencer",UVM_HIGH)
            `uvm_info("Test", $psprintf("Coverpoint coverage %p",
                        env_h.cov_h.get_cg_coverage()),UVM_LOW)

        end : stop_condition_thread
        
        join_any // wait for one of the threads to complete before dropping objection
    
        // ready to stop
        phase.drop_objection(this);           
    endtask: run_phase
    
endclass: random_test
