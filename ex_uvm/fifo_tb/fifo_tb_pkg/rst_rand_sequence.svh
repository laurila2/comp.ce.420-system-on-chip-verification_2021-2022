class rst_rand_sequence extends basic_sequence;
   `uvm_object_utils(rst_rand_sequence)

   int data_value = 1;
   int rst_counter = 0;
      
   function new(string name = "rst_rand_sequence");
      super.new(name);
   endfunction // new
   
   virtual task body ();
      
      // Handle for transaction
      transaction tx;
            
      repeat (1000) begin
	 
	 tx = transaction::type_id::create("tx");

	 /*
	 // Randomize
	 start_item(tx);
	 assert( tx.randomize() );
	 finish_item(tx);
	  */
	 
	 
	 // Randomize (debug)
	 start_item(tx);
	 assert( tx.randomize() with { data_to_DUT == data_value; } );
	 finish_item(tx);

	 data_value++;
	
	 start_item(tx);

	 if (rst_counter == 200) begin
	    rst_n = 1;
	 end
	 
	 rst_counter++;
	 	 
	        	 
      end // repeat (1000)
      
   endtask // body
      
endclass // rst_rand_sequence
