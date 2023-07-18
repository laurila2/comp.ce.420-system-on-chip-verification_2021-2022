
package system_map_pkg;

  import uvm_pkg::*;
  import uvm_register_pkg::*;
  
  import dut_ABC_rf_pkg::*;
  import dut_XYZ_rf_pkg::*;
  
  class dual_map extends uvm_register_map;
    dut_ABC_rf i1;
    dut_XYZ_rf i2;

    function new(string name, uvm_named_object p);
      super.new(name, p);
      uvm_report_info("dual_map", "new()");

      i1 = new("dut1", this);
      i2 = new("dut2", this);

      add_register_file(i1, 'h1000);
      add_register_file(i2, 'h2000);
    endfunction
  endclass

  class full_map extends uvm_register_map;
    dual_map i1;
    dut_ABC_rf i3;

    function new(string name, uvm_named_object p);
      super.new(name, p);
      uvm_report_info("full_map", "new()");

      i1 = new("dual_map", this);
      i3 = new("dut3", i1); // Parent is 'i1'.

      add_register_file(i1, 'h3000);
      add_register_file(i3, 'h0000);
    endfunction
  endclass

  //
  // A class to automatically load a register map.
  //
  class register_map_auto_load;

    // Triggers factory registration of this default
    //  sequence. Can be overriden by the user using
    //  "default_auto_register_test".
    register_sequence_all_registers
      #(uvm_register_transaction, 
        uvm_register_transaction) dummy;

    static bit loaded = build_register_map();

    static function bit build_register_map();

      full_map register_map;

      register_map = new("register_map", null);

      set_config_string("*", 
        "default_auto_register_test", 
        "register_sequence_all_registers#(REQ, RSP)");
      set_config_object("*", 
        "register_map", 
         register_map, 0);
      return 1;
    endfunction

  endclass
endpackage

