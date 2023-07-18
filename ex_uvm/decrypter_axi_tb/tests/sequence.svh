// ----------------------------------------------------------------------------
// sequence.svh
// ----------------------------------------------------------------------------
// UVM sequence class
// Defines the transactions to be driven to the DUT
// ----------------------------------------------------------------------------

class basic_sequence extends uvm_sequence #(axi_transaction);
    `uvm_object_utils(basic_sequence)

    function new(string name = "");
        super.new(name);
    endfunction: new

    task body;
    
        // handle for a transaction object
        axi_transaction tx;
        
        #4

        // Write to random address        
        tx = axi_transaction::type_id::create("tx");
        start_item(tx);
        assert( tx.randomize());
        finish_item(tx);
       
        // Write random data
        tx = axi_transaction::type_id::create("tx");
        start_item(tx);
        assert( tx.randomize() with { address == `DATA_ADDR;});
        finish_item(tx);

        // Write random data to invalid address
        tx = axi_transaction::type_id::create("tx");
        start_item(tx);
        assert( tx.randomize() with { address == `DATA_ADDR + 110;});
        finish_item(tx);

        // Write to random address        
        tx = axi_transaction::type_id::create("tx");
        start_item(tx);
        assert( tx.randomize());
        finish_item(tx);

        // Write random key
        tx = axi_transaction::type_id::create("tx");
        start_item(tx);
        assert( tx.randomize() with { address == `KEY_ADDR;});
        finish_item(tx);

        // Write random data
        tx = axi_transaction::type_id::create("tx");
        start_item(tx);
        assert( tx.randomize() with { address == `DATA_ADDR;});
        finish_item(tx);

        // Write another random data
        tx = axi_transaction::type_id::create("tx");
        start_item(tx);
        assert( tx.randomize() with { address == `DATA_ADDR;});
        finish_item(tx);
        
        // Write to random address        
        tx = axi_transaction::type_id::create("tx");
        start_item(tx);
        assert( tx.randomize());
        finish_item(tx);

    endtask: body

endclass: basic_sequence
