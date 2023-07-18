//-----------------------------------------------------
// hello.sv
//
// Hello world with SystemVerilog
// Displays a message and exits at 2ns
// Arto Oinonen 2019
//-----------------------------------------------------
module hello ;

  initial begin
    $display ("Hello World");
    $info ("SoC Verification");
    #2 $finish;
  end
endmodule: hello