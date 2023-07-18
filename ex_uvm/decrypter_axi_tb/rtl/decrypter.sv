//-----------------------------------------------------------------------------
// File        : decrypter.sv
// Description : Decrypter from SystemC exercises
// Author      : Arto Oinonen
// e-mail      : arto.oinonen@tut.fi
// Date        : 17.9.2015
// Modified    : 
//
// Decrypter with a Moore state machine. Performance can be increased
// by changing the structure.
// Decryption is done by:
// 1) bitwise XOR the encrypted data with the key
// 2) cut the data in half and rotate the halves
//-----------------------------------------------------------------------------

module decrypter #(
    parameter data_width_g = 32
    )(
    input                           clk,
    input                           rst_n,
    input                           enable_in,
    input        [data_width_g-1:0] key_in,
    input        [data_width_g-1:0] encrypted_in,
    output logic [data_width_g-1:0] decrypted_out,
    output logic                    valid_out
);
    // State variable for FSM
    typedef enum logic[2:0] {IDLE, PROCESSING, READY} trans_t;
    trans_t state;
  
    // Variable for permutated signal
    var logic    [data_width_g-1:0] data_xorred_v;
            
    always @ (posedge clk or negedge rst_n)
    
        // Reset all output registers and variables
        if (~rst_n) begin: on_rst
            valid_out      <= 1'b0;
            data_xorred_v  <= 0;
            decrypted_out  <= 0;
            state          <= IDLE;
        end: on_rst
        
        else begin: off_rst        
        
        // The state machine starts
            case (state)
                IDLE: begin: idle_state
                    if (enable_in) begin
                        state <= PROCESSING;
                    end
                    else 
                        state <= IDLE;
                        
                        valid_out <= 0;
                        decrypted_out  <= 0;
                        
                        
                end: idle_state

                PROCESSING: begin: processing_state

                    // Decrypt
                    data_xorred_v = encrypted_in ^ key_in;
                    
                    // Undo permutation
                    decrypted_out <= {data_xorred_v[data_width_g/2-1:0],
                      data_xorred_v[data_width_g-1:data_width_g/2]};
                    
                    if (enable_in)
                        state <= READY;
                end: processing_state
                        
                READY: begin: ready_state
                    valid_out <= 1;
                    // decrypted_out <= decrypted_out;
                    
                    if (enable_in)
                        state <= READY;
                    else 
                        state <= IDLE;
                end: ready_state

            endcase

        end: off_rst

// Assertions begin
// TODO
        
endmodule: decrypter


// testbench begins
module decrypter_tb;
    
    parameter data_width_g = 32;

    logic   clk, rst_n, enable_in, valid_out;
    logic [data_width_g-1:0] key_in, encrypted_in, decrypted_out;

    initial begin
        
        // Start a monitor that prints every time the decrypted_out changes
        $monitor("%h", decrypted_out);
        
        clk = 0;
        enable_in = 0;
        rst_n = 0;
        key_in = 0'hDEADBEEF;
        encrypted_in = 0'h00000000;
        #10 rst_n = 1;
        
        // Clean transfers, that should not fire assertions:
        repeat (10) begin
        encrypted_in = $urandom;
        #10 enable_in = 1;
        @(posedge valid_out);
        #10 enable_in = 0;
        end
        
        // Testing the assertions with dirty input
        $display("Assertion test begins at time %d ns", $time);
        
        // TODO: Add some input that breaks the specification to see
        // if the assertions fire
        
        
        #10 $finish;

    end
    
    // create clock
    always #5 clk =! clk;
    
    // Instantiate the DUT 
    decrypter #(.data_width_g(data_width_g)) DUT (
                .*
                );

endmodule: decrypter_tb
