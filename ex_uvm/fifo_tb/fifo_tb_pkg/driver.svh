// ----------------------------------------------------------------------------
// driver.svh
// ----------------------------------------------------------------------------
// UVM driver class
// ----------------------------------------------------------------------------

class driver extends uvm_driver #(transaction);

    `uvm_component_utils(driver)

    // declare a variable handle for the DUT interface and config object
    virtual dut_if dut_vi;
    dut_config dut_cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);

        // get dut config from config db
        if( !uvm_config_db #(dut_config)::get(this, "",
                        "dut_configuration", dut_cfg) )
        `uvm_fatal("NOVIF", "No virtual interface set");

        // connect the virtual interface handle
        dut_vi = dut_cfg.dut_vi;

        // debug prints
        `uvm_info("driver", "Created driver", UVM_HIGH)

    endfunction: build_phase

    task run_phase (uvm_phase phase);

        forever begin : pin_wiggle

        // create a handle for transaction
        // the transaction objects are created in the sequence
        transaction tx;

        // get a transaction object from the sequencer - blocking read
        seq_item_port.get_next_item(tx);

        // wait for clock edge
        @(posedge dut_vi.clk);

        // debug prints - verify transaction
        `uvm_info("driver", "Transaction received, wiggling pins", UVM_HIGH)

        // drive the individual DUT ports using the data from the transaction
        dut_vi.data_to_DUT = tx.data_to_DUT;
        dut_vi.we_out      = tx.write_enable;
        dut_vi.re_out      = tx.read_enable;

	// Prints for timing
	`uvm_info("tx data_to_DUT", $sformatf("val: %0d", tx.data_to_DUT), UVM_HIGH)
	`uvm_info("tx write enable", $sformatf("val: %0d", tx.write_enable), UVM_HIGH)
	`uvm_info("tx read enable", $sformatf("val: %0d", tx.read_enable), UVM_HIGH)
	   
        // tell the sequencer that we are done
        seq_item_port.item_done();

        end : pin_wiggle

    endtask: run_phase

endclass: driver
