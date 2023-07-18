module dut_ABC(interface i);
  reg [63:0] r1;
  reg [63:0] r2;

  reg [63:0] r1_resetVal = 'h12345678;
  reg [63:0] r2_resetVal = 'hdeadbeef;

  task reset();
    r1 <= 0;
    r2 <= 0;
    #10;
    r1 <= r1_resetVal;
    r2 <= r2_resetVal;
    #10;
  endtask

  initial begin
    $display(" HW_INFO @ %0t: Instantiated %m.r1", $time);
    $display(" HW_INFO @ %0t: Instantiated %m.r2", $time);
    reset();
  end

  always @(posedge i.r)
    reset();

  always @(r1)
    $display(" HW_INFO @ %0t: %m: r1 changed to %x", $time, r1);
  always @(r2)
    $display(" HW_INFO @ %0t: %m: r2 changed to %x", $time, r2);
endmodule

