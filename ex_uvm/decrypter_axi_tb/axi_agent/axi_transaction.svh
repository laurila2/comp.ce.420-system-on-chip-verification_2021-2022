// ----------------------------------------------------------------------------
// axi_transaction.svh
// ----------------------------------------------------------------------------
// Transaction class
// Responsible for containing a single packetful of transaction data
// and the constraints for it
// ----------------------------------------------------------------------------

class axi_transaction extends uvm_sequence_item;
    `uvm_object_utils(axi_transaction)

    // transaction data here (i.e. DUT's data, write_enable etc..)
    rand bit [31:0] address;
    rand bit [31:0] data;
    bit      [31:0] response;
    
	// TODO: Add address constraints with distributions
  
    function new(string name = "");
        super.new(name);
    endfunction: new
    
    // Convert2string function: can be used in prints
    function string convert2string;
      return $psprintf("addr=%h, data=%h, resp=%0d", address, data, response);
    endfunction: convert2string
       
endclass: axi_transaction
