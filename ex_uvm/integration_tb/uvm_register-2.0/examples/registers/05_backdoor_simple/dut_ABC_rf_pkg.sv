package dut_ABC_rf_pkg;

  import uvm_pkg::*;
  import uvm_register_pkg::*;

  typedef bit[63:0] bit64_t;

  class simple_value extends uvm_register #(bit64_t);
    function new(string name, uvm_named_object p, 
        bit64_t resetVal = 0);
      super.new(name, p, resetVal);
    endfunction

    function string convert2string();
      return $psprintf("%x", data);
    endfunction
  endclass

  class dut_ABC_rf extends uvm_register_file;
    simple_value r1;
    simple_value r2;

    function new(string name, uvm_named_object p);
      super.new(name, p);
      uvm_report_info("simple_register_file", "new()");

      // -----------------------
      // Construct the registers
      // -----------------------
      r1 = new("r1", this);
      r1.set_reset_value('h12345678);
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
