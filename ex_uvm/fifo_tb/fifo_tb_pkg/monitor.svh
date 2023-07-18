class monitor extends uvm_monitor;
   `uvm_component_utils (monitor)
   
   dut_config dut_cfg;
   virtual dut_if dut_vi;

   uvm_analysis_port #(transaction) ap;

   function new (string name = "monitor", uvm_component parent = null);
      super.new (name, parent);
   endfunction // new

   // Build the UVM monitor
   function void build_phase (uvm_phase phase);

      // Create an instance of the analysis port
      ap = new ("ap", this);

      // Get virtual interface handle from the configuration DB
      if ( !uvm_config_db #(dut_config)::get(this, "", "dut_configuration", dut_cfg)) begin
	 `uvm_error (get_type_name (), "DUT interface not found")
      end
      else
	dut_vi = dut_cfg.dut_vi;
      `uvm_info("monitor", "Created monitor", UVM_HIGH)
      
   endfunction // build_phase

   // run_phase
   task run_phase (uvm_phase phase);

      forever begin
	 transaction tx;
	 @(posedge dut_vi.clk)

	   tx = transaction::type_id::create("tx");
	 
	 tx.data_to_DUT = dut_vi.data_to_DUT;
	 `uvm_info("monitor, data_to_DUT", $sformatf("val: %0d", dut_vi.data_to_DUT), UVM_HIGH)
	 
	 tx.write_enable = dut_vi.we_out;
	 `uvm_info("monitor, data_to_DUT", $sformatf("val: %0d", dut_vi.we_out), UVM_HIGH)

	 tx.read_enable = dut_vi.re_out;
	 `uvm_info("monitor, re_out", $sformatf("val: %0d", dut_vi.re_out), UVM_HIGH)

	 tx.data_from_DUT = dut_vi.data_from_DUT;
	 `uvm_info("monitor, data_from_DUT", $sformatf("val: %0d", dut_vi.data_from_DUT), UVM_HIGH)

	 tx.full = dut_vi.full_in;
	 `uvm_info("monitor, full_in", $sformatf("val: %0d", dut_vi.full_in), UVM_HIGH)

	 tx.empty = dut_vi.empty_in;
	 `uvm_info("monitor, empty_in", $sformatf("val: %0d", dut_vi.empty_in), UVM_HIGH)

	 tx.one_p = dut_vi.one_p_in;
	 `uvm_info("monitor, one_p_in", $sformatf("val: %0d", dut_vi.one_p_in), UVM_HIGH)

	 tx.one_d = dut_vi.one_d_in;
	 `uvm_info("monitor, one_d_in", $sformatf("val: %0d", dut_vi.one_d_in), UVM_HIGH)
	 
	 `uvm_info("monitor", "Got data", UVM_HIGH)
	 ap.write(tx);

	 // Delta delay
	 #0;
	 
	 `uvm_info("monitor ap port", "writing", UVM_HIGH)
	 `uvm_info("monitor", $sformatf("val: %0d", tx), UVM_HIGH)
	 
      end 

   endtask // run_phase
   
endclass // monitor



