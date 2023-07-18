class coverage extends uvm_subscriber #(transaction);

   // Registeration macro
   `uvm_component_utils (coverage)

   // Add transaction variable
   transaction sample_tx;

   // Functionality
   covergroup cg_bus;
      c_data_to_DUT : coverpoint sample_tx.data_to_DUT;
      c_data_from_DUT : coverpoint sample_tx.data_from_DUT;
      c_data_empty : coverpoint sample_tx.empty;
      c_data_full : coverpoint sample_tx.full;
   endgroup // cg_bus

   // Covergroup constructor
   cg_bus = new();

   // Constructor
   function new (string name = "coverage", uvm_component parent = null);
      super.new (name, parent);
   endfunction // new

   // Build phase function with debug print
   function void build_phase(uvm_phase phase);
      `uvm_info("coverage", "Created Coverage Collector", UVM_HIGH)
   endfunction: build_phase

   // Interface through the transaction class
   function void write(transaction t);

      // Assign transaction (t) to sample_tx
      sample_tx = t;
      // Method to update the coverage information
      cg_bus.sample();

   endfunction: write

   function real get_cg_coverage();
      return cg_bus.get_coverage();
   endfunction: get_cg_coverage
   
endclass // coverage
