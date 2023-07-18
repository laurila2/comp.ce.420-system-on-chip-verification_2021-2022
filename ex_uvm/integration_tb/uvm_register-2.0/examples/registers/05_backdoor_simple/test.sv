package test_pkg;
  //
  // TODO: There must be a better way to 
  //       do string match and replacement.
  //       Use mti_dpi or import regex 
  //
  function string replace(
    string original_prefix, 
    string replacement_prefix, 
    string original_string);
  
    string new_string, p1, tail;
    int len;
  
    // 1. See if original string has the prefix.
    len = original_prefix.len();
    p1 = original_string.substr(0, len-1);
    if ( p1 == original_prefix ) begin
       // 2. Matching has started. We have a prefix.
       // 3. Get the tail of the original string -
       //    starting after the prefix 
       tail = original_string.substr(len, 
         original_string.len()-1);
       new_string = {replacement_prefix, tail};
uvm_report_info("REPLACE", $psprintf("Old Name = '%s'", original_string));
uvm_report_info("REPLACE", $psprintf("New Name = '%s'", new_string));
       return new_string;
    end
    // 4. No prefix. Is this an error?
    return original_string;
  endfunction
  
  // ----------------------------------------------------
  import uvm_pkg::*;
  import uvm_register_pkg::*;
  
  // Provokes the "auto_load" to build the register
  // map and load it into the config.
  import system_map_pkg::*;
  
  class a_test extends uvm_test;
  
    virtual my_bus_i vi;

    uvm_register_map rm;
    uvm_register_base registers[];
  
    function new(string name, uvm_component p);
      super.new(name, p);
    endfunction
  
    task run();
      int val_read;

      // Wait for the hardware to come out of reset.
      // A little bird told us is takes 20 ticks.
      #20;

      // Get a register map to use!
      //  Choice 1 - use get_config_object() yourself.
      //    uvm_object o;
      //    uvm_top.get_config_object("register_map", o);
      //    $cast(rm, o);
      //  Choice 2 - use the "register map static function"
      //    (which in turn uses the config...)
      rm = uvm_register_map::uvm_register_get_register_map();

      // The list of registers
      // 2.0 PORT registers = rm.get_register_array();
//2.0 PORT ** Error: test.sv(69): Function with return type of void cannot be used in/as an expression.
//2.0 PORT ** Error: test.sv(69): No actual value has been specified for a formal argument 'register_array' that does not have a default value.
//2.0 PORT ** Error: test.sv(69): Number of actuals and formals does not match in function call.
      rm.get_register_array(registers);
  
      // Setup the dut_register_names that 
      // will be used in backdoor-land.
      // It's a simple prefix replacement.
      // Replace "register_map.dual_map" with "top"
      // in the "full_name" of the register.
      //
      uvm_report_info("TEST", "Setting register HW/backdoor names");
      foreach (registers[i])
        // The 'dut_register_name' will be used by the PLI eventutally
        // to fetch the value.
        registers[i].set_dut_register_name(
          replace(
            "register_map.dual_map", 
            "top", 
            registers[i].get_full_name()
          )
        );
  
      // ---------------------------------------
      // First test. Write values, and read them.
      // All using the backdoor.
      //
      uvm_report_info("TEST", "Doing backdoor writes");
      foreach (registers[i])
        registers[i].backdoor_write(i);
  
      #100;

      uvm_report_info("TEST", "Doing backdoor reads");
      foreach (registers[i])
        registers[i].backdoor_read(val_read);


      // ---------------------------------------
      // Second test. Reset hardware and shadow.
      //
      uvm_report_info("TEST", "Doing shadow register reset()");
      foreach (registers[i])
        registers[i].reset();

      uvm_report_info("TEST", "Reseting the hardware");
      vi.reset();

      uvm_report_info("TEST", "Doing backdoor reads and compares");
      foreach (registers[i]) begin
        registers[i].backdoor_read(val_read);
        registers[i].bus_read32(val_read);
      end

      // Pretty print.
      rm.display_address_map();

      global_stop_request();
    endtask
  endclass
endpackage
