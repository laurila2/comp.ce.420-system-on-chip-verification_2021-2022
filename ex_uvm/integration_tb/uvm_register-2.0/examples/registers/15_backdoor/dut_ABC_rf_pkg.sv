package dut_ABC_rf_pkg;

  import uvm_pkg::*;
  import uvm_register_pkg::*;

  typedef bit[31:0] bit32_t;
  typedef struct packed {
    bit[15:0]a;
    bit[15:0]b;
  } r2_struct_t;

  class simple_value extends uvm_register #(bit32_t);
    function new(string name, uvm_named_object p);
      super.new(name, p);
	  set_reset_value('0);
    endfunction

    function string convert2string();
      return $psprintf("%x", data);
    endfunction
  endclass

  class my_counter extends uvm_register #(bit32_t);
    function new(string name, uvm_named_object p);
      super.new(name, p);
	  set_reset_value('0);
    endfunction

	function void write_without_notify(bit32_t v, bit32_t local_mask = '1);
	  poke(peek()+1);
	endfunction
  endclass

  class struct_value extends uvm_register #(r2_struct_t);
    function new(string name, uvm_named_object p, 
        bit32_t resetVal = 'hbbbbbbbb);
      super.new(name, p);
	  WMASK.a = 0;
      set_reset_value('hbbbbbbbb);
	  //data = resetVal;
	  uvm_report_info("struct", 
	    $psprintf("struct init data=%p, resetVal=%p", 
		  data, resetVal));
	  //reset();
    endfunction

    function string convert2string();
      return $psprintf("%x", data);
    endfunction
  endclass

  class dut_ABC_rf extends uvm_register_file;
    simple_value r1;
    struct_value r2;
	my_counter   r_counter;

    function new(string name, uvm_named_object p);
      super.new(name, p);
      uvm_report_info("simple_register_file", "new()");

      // -----------------------
      // Construct the registers
      // -----------------------
      r1 = new("r1", this);
	  r1.set_reset_value('h12345678);
      r2 = new("r2", this);
	  r1.set_reset_value('hdeadbeef);
	  r_counter = new("r_counter", this);

      // --------------------------------------
      // Add the registers to the register file
      // --------------------------------------
      add_register( r1.get_fullname(), 1, r1);
      add_register( r2.get_fullname(), 2, r2);
      add_register( r_counter.get_fullname(), 3, r_counter);
    endfunction
  endclass
endpackage
