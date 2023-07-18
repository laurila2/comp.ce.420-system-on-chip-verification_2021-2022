module dut_XYZ(interface i);
  reg [31:0] r1;
  reg [31:0] r2;

  task reset();
    r1 <= 0;
    r2 <= 0;
    #10;
    r1 <= 'h42; // Note: this is the WRONG reset value.
    r2 <= 'h42; //  It will cause a miscompare.
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

