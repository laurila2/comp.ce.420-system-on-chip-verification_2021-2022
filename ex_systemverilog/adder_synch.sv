module adder_synch #(parameter data_width_g = 8)
   (
    input [data_width_g-1:0] 	    operand_a_in,
    input [data_width_g-1:0] 	    operand_b_in,
    input 			    add_sub,
    input 			    clk,
    input 			    rst_n,

    output logic [data_width_g-1:0] result_out,
    output logic 		    carry_out
    );
   

   always_ff @(posedge clk or negedge rst_n) begin

      if (~rst_n) begin
	 result_out <= 0;
	 carry_out <= 0;
      end

      else begin

	 if (add_sub == 1) begin
	    {carry_out, result_out} <= operand_a_in + operand_b_in;
	 end

	 else begin
	    {carry_out, result_out} <= operand_a_in - operand_b_in;
	 end
      end
      
   end
   
endmodule: adder_synch


////////////////////////////////////////////////////////////
// Testbench starts here
////////////////////////////////////////////////////////////


// A testbench module for simulation

module adder_synch_tb ();

   // The width parameter can be declared as local here
   localparam data_width_g = 8;

   // Internal signals that are connected to the DUT
   // Signals are of type logic
   logic clk;
   logic rst_n;
   logic [7:0] operand_a_in;
   logic [7:0] operand_b_in;
   logic       add_sub;
   
   logic [7:0] result_out;
   logic       carry_out;

   ////////////////////////////////////////////////////////////
   // Procedures start here
   // - All the procedures (initial, always) run in parallel so 
   //   their order doesn't matter
   ////////////////////////////////////////////////////////////

   // Generate reset and some input in an initial block
   initial begin: initial_procedure

      // In the beginning, set reset and input signals to 0
      clk = 0;
      rst_n = 0;
      operand_a_in = 0;
      operand_b_in = 0;
      add_sub = 0;
      
      // Wait for 10 ns and then set the reset to 1
      #10 rst_n = 1;

      // After setting reset to 1, set some values to a_in and b_in
      #10 operand_a_in = 8'h64;
      operand_b_in = 8'h21;
      
      // A repeat loop, that randomizes the inputs 10 times every 10ns

      repeat(10) begin : random_loop
	 #10 operand_a_in = $urandom;
	 operand_b_in = $urandom;
	 add_sub = $urandom;
	 
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
   adder_synch DUT (
		    .operand_a_in(operand_a_in),
		    .operand_b_in(operand_b_in),
		    .clk(clk),
		    .rst_n(rst_n),
		    .add_sub(add_sub),
      
		    .result_out(result_out),
		    .carry_out(carry_out)				    
		    );
   
endmodule: adder_synch_tb
