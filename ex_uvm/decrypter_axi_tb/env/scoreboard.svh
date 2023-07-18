// ----------------------------------------------------------------------------
// scoreboard.svh
// ----------------------------------------------------------------------------
// UVM scoreboard class
// Follows both the DUT interfaces via analysis FIFOs and checks the output 
// of the DUT
// ----------------------------------------------------------------------------

class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)
            
    // Transaction handle
    axi_transaction  axi_tx;
    gpio_transaction gpio_tx;

    // Analysis export
    uvm_analysis_export #(axi_transaction)  axi_analysis_export;
    uvm_analysis_export #(gpio_transaction) gpio_analysis_export;
    
    // Analysis FIFOs
    uvm_tlm_analysis_fifo #(axi_transaction)  axi_fifo;
    uvm_tlm_analysis_fifo #(gpio_transaction) gpio_fifo;

    // DUT model
    int         decrypter_model_key    = 0;
    int         decrypter_model_xorred = 0;
    int         decrypter_model_output [$];
    int         decrypter_model_resp   = 0;

    function new(string name, uvm_component parent);
        super.new(name,parent);
        
        // Create analysis exports and fifos
        axi_analysis_export  = new("axi_analysis_export" , this);
        gpio_analysis_export = new("gpio_analysis_export", this);
        axi_fifo             = new("axi_fifo"            , this);
        gpio_fifo            = new("gpio_fifo"           , this);
        
    endfunction: new

    function void build_phase(uvm_phase phase);
        
        // Debug prints
        `uvm_info("scoreboard", "Created scoreboard", UVM_HIGH)
    
    endfunction: build_phase
    
    function void connect_phase(uvm_phase phase);
    
        // Connect analysis FIFOs
         axi_analysis_export.connect( axi_fifo.analysis_export);
        gpio_analysis_export.connect(gpio_fifo.analysis_export);
        
    endfunction: connect_phase
    
    task run();        
        // Read the AXI and GPIO monitors in separate threads 
        fork begin: read_axi
        
            forever begin: axi_loop

            // Read from the AXI FIFO
                axi_fifo.get(axi_tx);
                
                // If there was data, save it to the variable depending on address
                if (axi_tx.data) begin: axi_got_data
                    
                    // Got a key
                    if (axi_tx.address == `KEY_ADDR) begin: axi_got_key
                    
                        // Save the key
                        decrypter_model_key = axi_tx.data;

                        // Response = OK
                        decrypter_model_resp = 0;
                        
                    end: axi_got_key
                    
                    // Got encrypted data
                    else if (axi_tx.address == `DATA_ADDR) begin: axi_got_encrypted
                    
                        // key exists, decrypt data to model output
                        if (decrypter_model_key) begin: axi_got_encrypted_and_key_exists

                            decrypter_model_xorred = axi_tx.data ^ decrypter_model_key;
                            decrypter_model_output.push_back({decrypter_model_xorred[15:0],
                            decrypter_model_xorred[31:16]});

                            // Response = OK
                            decrypter_model_resp = 0;
                        end: axi_got_encrypted_and_key_exists 

                        // key has not been provided yet, generate SLVERR
                        else
                            decrypter_model_resp = 2;

                    end: axi_got_encrypted

                    // Address was on our range, but not valid
                    else if (!(axi_tx.address & `ADDR_MASK))
                        decrypter_model_resp = 3;

                    // else
                    // don't care about the data, if the address was not 
                    // on our range

                    // Check the response
                    a_correct_resp: assert (decrypter_model_resp == axi_tx.response)
                        `uvm_info("scoreboard", "Correct response from DUT", UVM_LOW)
                    else `uvm_error("scoreboard", "Response error")

                end: axi_got_data
                
                //Debug prints
                `uvm_info("scoreboard",axi_tx.convert2string, UVM_HIGH)
                
            end: axi_loop
        end: read_axi
            
        // Thread for DUT output comparison
        begin: read_gpio       
            forever begin: gpio_loop
        
                // Blocking read from gpio FIFO
                gpio_fifo.get(gpio_tx);
                
                // Data received - compare to the DUT
                if (gpio_tx.valid) begin: gpio_valid
                
                    // Check DUT output
                    a_correct_output: assert (decrypter_model_output.pop_front() == gpio_tx.decrypted)
                        `uvm_info("scoreboard", "Decrypt successful", UVM_LOW)
                    else `uvm_error("scoreboard", "Data mismatch in decryption")
            
                end: gpio_valid                
            end: gpio_loop            
        end: read_gpio
        
        // Run both threads endlessly
        join_none
            
    endtask: run
    
endclass: scoreboard
