// ----------------------------------------------------------------------------
// sequencer.svh
// ----------------------------------------------------------------------------
// UVM sequencer class
// ----------------------------------------------------------------------------

// Since using a vanilla sequencer is usually enough, there's no need to
// extend the base class

/*class sequencer extends uvm_sequencer #(transaction);
    `uvm_component_utils(sequencer)

    function new(string name, uvm_component parent);
        super.new(name);
    endfunction: new
endclass: sequencer
*/

// Use a typedef instead
typedef uvm_sequencer #(transaction) sequencer;
