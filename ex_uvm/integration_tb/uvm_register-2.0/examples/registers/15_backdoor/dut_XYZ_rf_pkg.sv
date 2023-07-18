package dut_XYZ_rf_pkg;

  import uvm_pkg::*;
  import uvm_register_pkg::*;

  typedef bit[31:0] bit32_t;

  class simple_value extends uvm_register #(bit32_t);
    function new(string name, uvm_named_object p);
      super.new(name, p);
	  set_reset_value('0);
    endfunction

    function string convert2string();
      return $psprintf("%x", data);
    endfunction
  endclass

  class dut_XYZ_rf extends uvm_register_file;
    simple_value r1;
    simple_value r2;

    function new(string name, uvm_named_object p);
      super.new(name, p);
      uvm_report_info("simple_register_file", "new()");

      // -----------------------
      // Construct the registers
      // -----------------------
      r1 = new("r1", this);
      r2 = new("r2", this);
      r2.set_reset_value('hdeadbeef);

      // --------------------------------------
      // Add the registers to the register file
      // --------------------------------------
      add_register( r1.get_fullname(), 1, r1);
      add_register( r2.get_fullname(), 2, r2);
    endfunction
  endclass
endpackage
