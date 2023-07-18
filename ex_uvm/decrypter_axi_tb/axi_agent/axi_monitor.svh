// ----------------------------------------------------------------------------
// axi_monitor.svh
// ----------------------------------------------------------------------------
// Monitor for AXI4-Lite interface
// 
// Reads the bus and sends the transactions in a package that includes information
// from all the channels
//
// Possible sequences:
// Address - data - response
// Address - Address. Send only the first one and save the later one for next transaction
// data - response. Use saved address, as in the DUT specification
// ----------------------------------------------------------------------------

class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)

    // Handles for the DUT interface
    axi_dut_config dut_cfg;
    virtual axi_if axi_vi;
    
    // Variable to store the address
    int address_cache;
    
    // Analysis port
    uvm_analysis_port #(axi_transaction) ap;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new
    
    // Build phase method
    function void build_phase(uvm_phase phase);
        
        // Get the dut configuration from the config db
        if( !uvm_config_db #(axi_dut_config)::get(this, "", "axi_dut_configuration", dut_cfg) )
                `uvm_fatal("NOVIF", "No virtual interface set");

        // Connect it to the handle
        axi_vi = dut_cfg.axi_vi;
        
        // Create analysis port
        ap = new("ap", this);

        // Debug prints
        `uvm_info("axi_monitor", "Created axi_monitor", UVM_HIGH)
    
    endfunction: build_phase
    
    // Run phase method
    task run_phase (uvm_phase phase);

        // Transaction handle
        axi_transaction tx;
    
        forever begin: monitor_loop

            // Create transaction object
            tx = axi_transaction::type_id::create("tx");
    
            // Wait for a channel ready to be read
            @(posedge (axi_vi.waddr_channel.ready & axi_vi.waddr_channel.valid) |
                      (axi_vi.wdata_channel.ready & axi_vi.wdata_channel.valid) |
                      (axi_vi.wresp_channel.ready & axi_vi.wresp_channel.valid));

            // If address was sent, save it to a variable and wait for next transaction
            if(axi_vi.waddr_channel.ready && axi_vi.waddr_channel.valid) begin: address_was_first
                address_cache = axi_vi.waddr_channel.information;
                tx.address    = address_cache;
                
                // Wait for next transaction
                @(posedge (axi_vi.waddr_channel.ready & axi_vi.waddr_channel.valid) |
                          (axi_vi.wdata_channel.ready & axi_vi.wdata_channel.valid) |
                          (axi_vi.wresp_channel.ready & axi_vi.wresp_channel.valid));
                
                // Another address - read it and break the loop
                if(axi_vi.waddr_channel.ready && axi_vi.waddr_channel.valid) begin: another_address

                    // Send the previous address in the transaction and save the 
                    // new one for next round
                    address_cache = axi_vi.waddr_channel.information;
                end: another_address                
            end: address_was_first

            else // Address was not the first object - use the saved address
                tx.address    = address_cache;
            
            // If data was sent, read it to transaction and wait for response
            if(axi_vi.wdata_channel.ready && axi_vi.wdata_channel.valid) begin: data_sent
                tx.data = axi_vi.wdata_channel.information;
                
                // Read response
                @(posedge (axi_vi.wresp_channel.ready & axi_vi.wresp_channel.valid));
                tx.response = axi_vi.wresp_channel.information;
            end: data_sent

            // Copy transaction data
            //tx.address   = axi_vi.waddr_channel.information;
            //tx.data      = axi_vi.wdata_channel.information;
            //tx.response  = axi_vi.wresp_channel.information;

            // Write transaction
            ap.write(tx);

            //Debug prints
            `uvm_info("axi_monitor",tx.convert2string, UVM_HIGH)
            
        end: monitor_loop    
        
    endtask: run_phase
    
endclass: axi_monitor
