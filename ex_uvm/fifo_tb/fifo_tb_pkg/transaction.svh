// ----------------------------------------------------------------------------
// transaction.svh
// ----------------------------------------------------------------------------
// Transaction class
// Responsible for containing a single packetful of transaction data
// and the constraints for it
// ----------------------------------------------------------------------------
// Note: extending uvm_sequence_item, not its parent uvm_transaction
// ----------------------------------------------------------------------------

class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction)

    // transaction data here (i.e. DUT's data, write_enable etc..)
    rand bit  [31:0]  data_to_DUT;
    rand bit          write_enable;
    rand bit          read_enable;
    bit	              rst_n;
    bit       [31:0]  data_from_DUT;
    bit               full;
    bit	              empty;
    bit	              one_p;
    bit	              one_d;

    function new(string name = "");
        super.new(name);
    endfunction: new

    // Example of convert2string(): Modify to your liking
    function string convert2string();
        string s;
        $sformat(s, "%s\n", super.convert2string());
        $sformat(s, "%s DATA_TO:\t%8h\n DATA_FROM:\t%8h\n", s, data_to_DUT, data_from_DUT);
        return s;
    endfunction:convert2string

endclass: transaction
