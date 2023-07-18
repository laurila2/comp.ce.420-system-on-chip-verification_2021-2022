// ----------------------------------------------------------------------------
// gpio_transaction.svh
// ----------------------------------------------------------------------------
// Transaction class
// Responsible for containing a single packetful of transaction data
// and the constraints for it
// ----------------------------------------------------------------------------

class gpio_transaction extends uvm_sequence_item;
    `uvm_object_utils(gpio_transaction)

    // transaction data here (i.e. DUT's data, write_enable etc..)
    bit        valid;
    bit [31:0] decrypted;

    // add constraints for transaction data if required
    // data constraint example:
    // constraint c_data {data_to_DUT >= 0;}
    
    function new(string name = "");
        super.new(name);
    endfunction: new
    
    function string convert2string;
      return $psprintf("data=%h, valid=%b", decrypted, valid);
    endfunction: convert2string
       
endclass: gpio_transaction
