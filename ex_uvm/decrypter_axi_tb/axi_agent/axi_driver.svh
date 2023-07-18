// ----------------------------------------------------------------------------
// axi_driver.svh
// ----------------------------------------------------------------------------
// UVM driver class
// ----------------------------------------------------------------------------

class axi_driver extends uvm_driver #(axi_transaction);

    `uvm_component_utils(axi_driver)

    // declare a variable handle for the DUT interface and config object
    virtual axi_if axi_vi;
    axi_dut_config dut_cfg;

    int address  = 0;
    int response = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
    
        // get dut config from config db
        if( !uvm_config_db #(axi_dut_config)::get(this, "",
                    "axi_dut_configuration", dut_cfg) )
        `uvm_fatal("NOVIF", "No virtual interface set");
    
        // connect the virtual interface handle
        axi_vi = dut_cfg.axi_vi;
    
        // debug prints
        `uvm_info("axi_driver", "Created axi_driver", UVM_HIGH)
    
    endfunction: build_phase
    
    task run_phase (uvm_phase phase);
    
        // create a handle for transaction
        axi_transaction tx;
        
        // A variable to store the latest address

        forever begin : pin_wiggle

            // Create a transaction
            tx = axi_transaction::type_id::create("tx");

            // ask for a transaction from the sequencer - blocking read
            seq_item_port.get_next_item(tx);

            // wait for clock edge
            @(posedge axi_vi.clk);

            // Debug: Print the transaction contents
            `uvm_info("axi_driver",tx.convert2string, UVM_HIGH)

            // Address has changed - write the new one to the DUT
            if (address != tx.address) begin: write_new_address
                axi_write_address(tx.address);
                address = tx.address;
            end: write_new_address

            // Write data only if address is on our range
            // DUT ignores other addresses
			if (!(address & `ADDR_MASK))
                axi_write_data(tx.data);

            // tell the sequencer that we are done
            seq_item_port.item_done();

        end : pin_wiggle

    endtask: run_phase
    
    // Tasks for AXI write    
    task axi_write_address (int address);

        // Write address
        axi_vi.waddr_channel.information = address;
        axi_vi.waddr_channel.valid = 1; 

        // Write done - clear
        @(negedge axi_vi.waddr_channel.ready);
        axi_vi.waddr_channel.valid = 0;
        axi_vi.waddr_channel.information = 0;

        endtask
    
    task axi_write_data (int data);

        // Write data
        axi_vi.wdata_channel.information = data;
        axi_vi.wdata_channel.valid = 1; 

        // Write done - clear
        @(negedge axi_vi.wdata_channel.ready);
        axi_vi.wdata_channel.valid = 0;
        axi_vi.wdata_channel.information = 0;

        // Ready for the response
        axi_vi.wresp_channel.ready = 1; 
        
        // Read the response when valid and clear ready
        @(axi_vi.wresp_channel.valid);
        response = axi_vi.wresp_channel.information;
        @(negedge axi_vi.wresp_channel.valid);
        axi_vi.wresp_channel.ready = 0;
    endtask
    
endclass: axi_driver

