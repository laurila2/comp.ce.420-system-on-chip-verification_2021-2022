class scoreboard extends uvm_scoreboard;
   `uvm_component_utils(scoreboard)

   // Local variables
   int data_to_DUT_local = 0;
   int data_from_DUT_local = 0;
  
   int queue_size_tmp = 0;
   
   bit write_enable_local = 'b0;
   bit read_enable_local = 'b0;

   // Declare an analysis export
   uvm_analysis_imp #(transaction, scoreboard) analysis_export;

   // Systemverilog queue
   int queue[$];
      
   // new - constructor
   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      // Create an instance of analysis export
      analysis_export = new("analysis_export", this);
      
   endfunction: build_phase

   // Write function
   virtual function void write(transaction t);
      queue_size_tmp = queue.size();
      
      // read enable 1
      if (read_enable_local) begin
	 if (queue.size() > 0) begin
	    
	    // comparison	    
	    if (t.data_from_DUT == queue[0]) begin
	       // match
	    end
	    else begin
	       `uvm_error("read", "data_from_DUT doesnt match scoreboard ref-FIFO!!")
	       `uvm_info("read, ref-FIFO", $sformatf("val: %x", queue[0]), UVM_HIGH)
	       `uvm_info("read, data_from_DUT", $sformatf("val: %x", t.data_from_DUT), UVM_HIGH)
	    end
	    
	  // Delete oldest value from queue
	  queue.pop_front();
	    
	 end // if (queue.size() > 0)
      end // if (t.read_enable)

      // write enable 1
      if (write_enable_local) begin
	 	 
	 if (queue_size_tmp < 5) begin
	    queue.push_back(data_to_DUT_local);
	    end
      end

      // Check for Empty
      if (t.empty) begin
	 if(queue_size_tmp == 0) begin
	    // match
	 end
	 else begin
	    `uvm_error("empty", "empty doesnt match scoreboard ref-FIFO!!")
	 end
      end

      // Check for Full
      if (t.full) begin
	 if(queue_size_tmp == 5) begin
	    // match
	 end
	 else begin
	    `uvm_error("full", "full doesnt match scoreboard ref-FIFO!!")
	 end
      end

      // Check for one_p
      // FIFO has one free space for data to be written --> one_p is high
      if (t.one_p) begin
	 if (queue_size_tmp == 4) begin
	    //match
	 end
	 else begin
	    `uvm_error("one_p", "one_p doesnt match scoreboard ref-FIFO!!")
	 end
      end

      // Check for one_d
      // FIFO has one data cell to be read --> one_d is high
      if (t.one_d) begin
	 if (queue_size_tmp == 1) begin
	    //match
	 end
	 else begin
	    `uvm_error("one_d", "one_d doesnt match scoreboard ref-FIFO!!")
	 end
      end
      
      data_to_DUT_local = t.data_to_DUT;
      data_from_DUT_local = t.data_from_DUT;
      write_enable_local = t.write_enable;
      read_enable_local = t.read_enable;
           
   endfunction: write
   
endclass : scoreboard
