class random_test extends test_base;
   `uvm_component_utils(random_test)

   // Constructor
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction // build_phase

   task run_phase(uvm_phase phase);
      // raise objection to notify that the testing isn't done yet
      phase.raise_objection(this);
      // create a random sequence
      seq_h = rand_sequence::type_id::create("seq_h");
      seq_h.start( env_h.agent_h.seqr_h );
            
      // ready to stop
      phase.drop_objection(this);

   endtask: run_phase

endclass // random_test

   
   
   
