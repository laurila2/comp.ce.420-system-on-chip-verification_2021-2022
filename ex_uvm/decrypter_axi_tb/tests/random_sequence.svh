// ----------------------------------------------------------------------------
// random_sequence.svh
// ----------------------------------------------------------------------------
// UVM sequence class
// Defines the transactions to be driven to the DUT
// ----------------------------------------------------------------------------

class random_sequence extends basic_sequence;
    `uvm_object_utils(random_sequence)

    function new(string name = "");
        super.new(name);
    endfunction: new

    task body;
    
        // create a transaction object for driving the DUT
        axi_transaction tx;
        
        // debug prints
        `uvm_info("sequence", "Created a transaction object", UVM_HIGH)

        // First write the data before key to get a SLVERR from DUT
        tx = axi_transaction::type_id::create("tx");
        start_item(tx);
        assert( tx.randomize() with {tx.address == `DATA_ADDR; });
        finish_item(tx);

       // loop until stopped by the test
        forever begin : sequence_loop

            // randomize input
            tx = axi_transaction::type_id::create("tx");
            start_item(tx);
            assert( tx.randomize() );
            finish_item(tx);

        end : sequence_loop
    endtask: body

endclass: random_sequence
