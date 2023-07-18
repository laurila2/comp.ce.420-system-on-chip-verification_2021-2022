module dut_ABC(interface i);
  reg [31:0] r1;
  reg [31:0] r2;
  reg [31:0] r_counter;

  reg [31:0] r1_resetVal = 'h12345678;
  reg [31:0] r2_resetVal = 'hdeadbeef;
  reg [31:0] r_counter_resetVal = 'h0;

  task reset();
    r1 <= 0;
    r2 <= 0;
	r_counter <= 0;
    #10;
    r1 <= r1_resetVal;
    r2 <= r2_resetVal;
	r_counter <= r_counter_resetVal;
    #10;
  endtask

  initial begin
    $display(" HW_INFO @ %0t: Instantiated %m.r1", $time);
    $display(" HW_INFO @ %0t: Instantiated %m.r2", $time);
    $display(" HW_INFO @ %0t: Instantiated %m.r_counter", $time);
    reset();
  end

  always @(posedge i.r)
    reset();

  always @(r1)
    $display(" HW_INFO @ %0t: %m: r1 changed to %x", $time, r1);
  always @(r2)
    $display(" HW_INFO @ %0t: %m: r2 changed to %x", $time, r2);
  always @(r_counter)
    $display(" HW_INFO @ %0t: %m: r_counter changed to %x", $time, r_counter);
endmodule

