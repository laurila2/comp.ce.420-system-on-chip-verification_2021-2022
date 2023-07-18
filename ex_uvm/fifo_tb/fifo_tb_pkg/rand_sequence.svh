class rand_sequence extends basic_sequence;
   `uvm_object_utils(rand_sequence)

   //int data_value = 1;
   
   function new(string name = "rand_sequence");
      super.new(name);
   endfunction // new
   
   virtual task body ();
      //`uvm_info("RAND_SEQ", $sformatf ("Starting body of %s", this.get_name()), UVM_MEDIUM)

      // Handle for transaction
      transaction tx;
            
      repeat (1000) begin
	 
	 tx = transaction::type_id::create("tx");

	 
	 // Randomize
	 start_item(tx);
	 assert( tx.randomize() );
	 finish_item(tx);
	 

	 /*
	 // Randomize (debug)
	 start_item(tx);
	 assert( tx.randomize() with { data_to_DUT == data_value; } );
	 finish_item(tx);
	 
	 data_value++;
	  */
	        	 
      end // repeat (1000)
      
   endtask // body
      
endclass // rand_sequence
