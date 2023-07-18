module adder (operand_a_in, operand_b_in, carry_out, result_out);

   // Inputs
   input [7:0] operand_a_in;
   input [7:0] operand_b_in;

   // Outputs
   output      carry_out;
   output [7:0] result_out;

   assign {carry_out, result_out} = operand_a_in + operand_b_in;

   


   
endmodule: adder
