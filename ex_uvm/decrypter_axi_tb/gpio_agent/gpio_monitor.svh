// ----------------------------------------------------------------------------
// gpio_monitor.svh
// ----------------------------------------------------------------------------
// Monitor for GPIO interface
// 
// Sends the data to analysis port every time the valid signal rises
// - Doesn't monitor the data when not valid
// ----------------------------------------------------------------------------
class gpio_monitor extends uvm_monitor;
    `uvm_component_utils(gpio_monitor)

    // Handles for the DUT interface
    gpio_dut_config dut_cfg;
    virtual gpio_if gpio_vi;
    
    // Analysis port
    uvm_analysis_port #(gpio_transaction) ap;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new
    
    // Build phase method
    function void build_phase(uvm_phase phase);

        // Get the dut configuration from the config db
        if( !uvm_config_db #(gpio_dut_config)::get(this, "", "gpio_dut_configuration", dut_cfg) )
                `uvm_fatal("NOVIF", "No virtual interface set");

        // Connect it to the handle
        gpio_vi = dut_cfg.gpio_vi;
        
        // Create analysis port
        ap = new("ap", this);

        // Debug prints
        `uvm_info("gpio_monitor", "Created gpio_monitor", UVM_HIGH)

    endfunction: build_phase
    
    // Run phase method
    task run_phase (uvm_phase phase);

        // Transaction handle
        gpio_transaction tx;
    
        forever begin: monitor_loop

            // Create transaction object
            tx = gpio_transaction::type_id::create("tx");
    
            // Monitor every time valid changes
            @(posedge gpio_vi.valid);
            
            // Copy DUT state to transaction object
            tx.valid = gpio_vi.valid;
            tx.decrypted = gpio_vi.decrypted;

            // Write transaction
            ap.write(tx);

            //Debug prints
            `uvm_info("gpio_monitor",tx.convert2string, UVM_HIGH)
            
        end: monitor_loop
        
    endtask: run_phase
    
endclass: gpio_monitor
