//-----------------------------------------------------------------------------
// File        : decrypter_axi_wrapper.sv
// Description : AXI4-Lite wrapper for Decrypter module
// Author      : Arto Oinonen
// e-mail      : arto.oinonen@tut.fi
// Date        : 7.10.2015
// Modified    : 
//
//-----------------------------------------------------------------------------

// define macros for addresses. Usage example: write_addr(`KEY_ADDR);
`include "axi_defines.svh"

// Signals of one AXI-Lite channel
interface axi_channel #(parameter data_width_g = 32);
    logic [data_width_g-1:0] information;
    logic valid;
    logic ready;
    
    // Modport for input channels - write address, data
    modport target (
        input  information,
        input  valid,
        output ready
    );

    // Modport for output channels - write response
    modport source (
        input  ready,
        output information,
        output valid
    );
    
endinterface

module decrypter_axi_wrapper #(
    parameter data_width_g = 32
    )(
    input clk,
    input rst_n,
    
    // AXI channel interfaces - instantiated in the testbench, connected here
    // using modports for directions
    
    axi_channel.target waddr_channel,
    axi_channel.target wdata_channel,
    axi_channel.source wresp_channel,
        
    // Output signals
    output logic valid_from_dec_out,
    output logic [data_width_g-1:0] decrypted_from_dec_out
    );
    
    // Local registers
    logic                    enable_to_dec_r;
    logic [data_width_g-1:0] key_to_dec_r;
    logic [data_width_g-1:0] encrypted_to_dec_r;
    logic [data_width_g-1:0] address_r;
    
    typedef enum {NULL,OKAY,EXOKAY,SLVERR,DECERR} response_type;
    response_type response_v;
    
    always @(posedge clk or negedge rst_n)
        if (~rst_n) begin: on_reset
        
            // Bus signals and variables
            waddr_channel.ready <= 0;
            wdata_channel.ready <= 0;
            wresp_channel.valid <= 0;
            address_r           <= 0;
            response_v          <= NULL;
            
            //Decrypter signals
            encrypted_to_dec_r  <= 0;
            key_to_dec_r        <= 0;
            enable_to_dec_r     <= 0;
            
            // Output
            
        end: on_reset
        
        else begin: off_reset
        
            // Decrypter output is valid => read and set enable to 0
            if (valid_from_dec_out) 
                enable_to_dec_r <= 0;
        
			// raise ready signal for address channel to allow transfer
			waddr_channel.ready <= 1;

			// Address exists and the decoder is idle - raise data ready
			// Does not care yet if the address is valid
			// Also wait for the response of the previous transfer to be transmitted
			// before accepting new data
			if (address_r && ~enable_to_dec_r && response_v == NULL)
				wdata_channel.ready <= 1;
			else wdata_channel.ready <= 0;

			// Got address valid - Read address and lower the ready
			if (waddr_channel.valid && waddr_channel.ready) begin: read_address
				
				// Check if the address is on our range - don't save it if not
				if (!(waddr_channel.information & `ADDR_MASK))
					address_r <= waddr_channel.information;
					
				// Clear ready in every case, because otherwise it will hang the master
				waddr_channel.ready <= 0;
				
			end: read_address
	        
			// Got data valid - Read data and lower the ready
			if (wdata_channel.valid && wdata_channel.ready) begin: read_data
				
				// Address points to key - read it
				if (address_r == `KEY_ADDR) begin: read_key
					key_to_dec_r <= wdata_channel.information;
					wdata_channel.ready <= 0;
					// Produce OK response on next cycle
					response_v <= OKAY;
					
				end: read_key
				
				// Address points to encrypted value - 
				//read it and set enable for the decrypter
				else if (address_r == `DATA_ADDR) begin: read_encrypted
					
					// Read encrypted signal only if the key has been specified
					if (key_to_dec_r) begin: read_encrypted_ok
						encrypted_to_dec_r <= wdata_channel.information;
						wdata_channel.ready <= 0;
						response_v <= OKAY;
						enable_to_dec_r <= 1;
					end: read_encrypted_ok
					
					// Produce slave error if key has not been specified yet
					else begin: read_encrypted_nokey_error
						response_v <= SLVERR;
						wdata_channel.ready <= 0;
					end: read_encrypted_nokey_error
				  
				end: read_encrypted

				// Address was not valid - Produce decode error
				else begin: read_dec_error
					wdata_channel.ready <= 0;
					response_v <= DECERR;
				end: read_dec_error
			end: read_data
            
			// Deliver response, if there is one in the buffer
			if (response_v != NULL) begin: response_cycle
                
                // Write the response buffer to response channel
                case (response_v)
                
                OKAY:
                    wresp_channel.information = 2'b00;
                
                EXOKAY: //Should never exist in AXI4-Lite bus
                    wresp_channel.information = 2'b01;
                
                SLVERR:
                    wresp_channel.information = 2'b10;
                
                DECERR:
                    wresp_channel.information = 2'b11;
					
				// NULL: should never appear here
                
                endcase

                // Set valid 
                wresp_channel.valid <= 1;
                
                // Master is ready and has read the data - drop valid, 
                // clear response channel and empty the buffer
                if (wresp_channel.valid && wresp_channel.ready) begin: write_response
                    wresp_channel.valid <= 0;
                    wresp_channel.information <= 0;
                    response_v <= NULL;
                end: write_response
                
            end: response_cycle
            
        end: off_reset
    
    // Instantiate the decrypter module
    decrypter #(.data_width_g(data_width_g)) i_decrypter
    (
    .clk            (clk),
    .rst_n          (rst_n),
    .enable_in      (enable_to_dec_r),
    .key_in         (key_to_dec_r),
    .encrypted_in   (encrypted_to_dec_r),
    .decrypted_out  (decrypted_from_dec_out),
    .valid_out      (valid_from_dec_out)      
    );
        
endmodule: decrypter_axi_wrapper


// Testbench begins
module decrypter_axi_wrapper_tb;
    
    parameter data_width_g = 32;
    logic clk = 0;
    logic rst_n = 0;

    // Instantiate interfaces
    axi_channel #(.data_width_g(data_width_g)) waddr_channel();
    axi_channel #(.data_width_g(data_width_g)) wdata_channel();
    axi_channel #(.data_width_g(2))            wresp_channel();
    
    // DUT output signals
    logic [data_width_g-1:0] decrypted_from_dec_out;
    logic valid_from_dec_out;
    
    initial begin
        // Clear signals
        waddr_channel.valid = 0;
        waddr_channel.information = 0;
        wdata_channel.valid = 0;
        wdata_channel.information = 0;
        wresp_channel.ready = 0;
        wresp_channel.information = 0;
        
        // Begin
        #10 rst_n = 1;        

        // Write a random address
        // That the DUT should not register 
        write_address($urandom);

        // Write data before key - should produce SLVERR
        write_address(`DATA_ADDR);
        write_data($urandom);

        // Write random key
        write_address(`KEY_ADDR);
        write_data($urandom);
        
        // Write data address
        write_address(`DATA_ADDR);

        // loop: write 20 random data        
        repeat(20) begin 
            write_data($urandom);
        end
                
        // Write to invalid address on the correct range - Should produce DECERR
        write_address(`DATA_ADDR+166);
        write_data($urandom);
        
        // Finished
        #10 $finish;
    end
   // create clock
   always begin
      #5 clk =! clk;
   end

    decrypter_axi_wrapper #(.data_width_g(data_width_g)) DUT(.*);

    // Tasks for abstracting the reading and writing:
    
    // Write address using AXI4-Lite handshaking
    task write_address (input [data_width_g-1:0] address);
        // Write address
        waddr_channel.information = address;
        waddr_channel.valid = 1; 
        
        // Write done - clear
        @(negedge waddr_channel.ready);
        $display("Write to address: %h", waddr_channel.information);
        waddr_channel.valid = 0;
        waddr_channel.information = 0;
    endtask
    
    // Write address and read response using AXI4-Lite handshaking
    task write_data (input [data_width_g-1:0] address);
        // Write data
        wdata_channel.information = address;
        wdata_channel.valid = 1; 
        
        // Write done - clear
        @(negedge wdata_channel.ready);
        $display("written: %h", wdata_channel.information);
        wdata_channel.valid = 0;
        wdata_channel.information = 0;

        // Ready for the response
        wresp_channel.ready = 1; 
        
        // Read the response when valid and clear ready
        @(wresp_channel.valid);
        $display("Got response: %h", wresp_channel.information);
        @(negedge wresp_channel.valid);
        wresp_channel.ready = 0; 
    endtask

endmodule: decrypter_axi_wrapper_tb
