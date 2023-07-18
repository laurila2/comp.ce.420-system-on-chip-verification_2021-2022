// pass_through.sv
// This is a code example of a simple testbench design
// The module feeds inputs a and b through 
// to outputs x and y

// The module parameter data_width_g has a default value of 8
// The testbench can override the default value when instantiating
// module
module pass_through #(parameter data_width_g = 8)(

//Module inputs and outputs
input clk,
input rst_n,
input [7:0] a_in,
input [7:0] b_in,

// Because the X and Y outputs are set in an always_ff block and not continuously
// Set their data type to logic
// - The default is usually wire if not specified otherwise

output logic [7:0] x_out,
output logic [7:0] y_out
);

always_ff @(posedge clk or negedge rst_n)
    // Clear all output registers on reset
    if (~rst_n) begin
        x_out <= 0;
        y_out <= 0;
    end

    // Operation when not in reset
    else begin
        // Assign the signals (non-blocking assignment)
        x_out <= a_in;
        y_out <= b_in;

    end
endmodule: pass_through


////////////////////////////////////////////////////////////
// Testbench starts here
////////////////////////////////////////////////////////////


// A testbench module for simulation
// A testbench doesn't have any inputs or outputs, so the port list is empty
module pass_through_tb ();
    
    // The width parameter can be declared as local here
    localparam data_width_g = 8;
    
    // Internal signals that are connected to the DUT
    // Signals are of type logic
    logic clk;
    logic rst_n;
    logic [7:0] b_in;
    logic [7:0] a_in;
    logic [7:0] x_out;
    logic [7:0] y_out;
    
    ////////////////////////////////////////////////////////////
    // Procedures start here
    // - All the procedures (initial, always) run in parallel so 
    //   their order doesn't matter
    ////////////////////////////////////////////////////////////
    
    
    // Generate reset and some input in an initial block
    initial begin: initial_procedure // initial_procedure is the LABEL of the BEGIN-END block
                                     // Adding labels make the code more readable, because
                                     // it's easy to see what ends in the END statement
    
        // In the beginning, set reset and input signals to 0
        clk = 0; // Set clk to 0 in the beginning, so it can be toggled in the always block later
        rst_n = 0;
        a_in = 0;
        b_in = 0;
        
        // Wait for 10 ns and then set the reset to 1
        #10 rst_n = 1;
        
        // After setting reset to 1, set some values to a_in and b_in
        #10 a_in = 8'h64;
            b_in = 8'h21;
            
        // A repeat loop, that randomizes the inputs 10 times every 10ns
        
        repeat(10) begin : random_loop
        #10 a_in = $urandom;
            b_in = $urandom;
        end : random_loop

        // The sequence is completed, so the initial block is processed
        // wait another 10 ns and then finish the simulation
        #10 $finish;        
    end : initial_procedure
    
    
    // Create clock in an always block
    // Cycle = 10ns
    always #5 clk =! clk;

    // Instantiate the DUT - in other words connect it to the testbench
    // Also deliver the parameter to the DUT
    pass_through #(.data_width_g(data_width_g)) DUT (.*);
        
endmodule: pass_through_tb