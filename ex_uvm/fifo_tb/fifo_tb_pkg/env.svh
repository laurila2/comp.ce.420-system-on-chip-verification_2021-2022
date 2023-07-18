// ----------------------------------------------------------------------------
// env.svh
// ----------------------------------------------------------------------------
// UVM environment class
// ----------------------------------------------------------------------------

class env extends uvm_env;
    `uvm_component_utils(env)

    // Component handles
    agent agent_h;
    coverage subscriber_h;
    scoreboard scoreboard_h;
   
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);

        // create agent
        agent_h = agent::type_id::create("agent_h",this);

        // debug prints
        `uvm_info("env","Created environment", UVM_HIGH)

       // create subscriber
       subscriber_h = coverage::type_id::create("subscriber_h", this);
       scoreboard_h = scoreboard::type_id::create("scoreboard_h", this);
       
       // debug prints
       `uvm_info("env","Created subscriber", UVM_HIGH)

    endfunction: build_phase

   virtual function void connect_phase (uvm_phase phase);
      // Connect the agent_h
      agent_h.ap.connect(subscriber_h.analysis_export);
      agent_h.ap.connect(scoreboard_h.analysis_export);
      
   endfunction // connect_phase
      
endclass: env
