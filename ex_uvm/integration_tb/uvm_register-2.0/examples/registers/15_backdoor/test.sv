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
	uvm_register_base r;
	string register_name;
  
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


	  // Initial state - before anything happens. What are
	  // the values in the shadow?
      // Pretty print.
      uvm_report_info("TEST", "Register Initial values");
      rm.display_address_map();

      foreach (registers[i])
	    registers[i].reset();

      uvm_report_info("TEST", "Register Reset values");
      rm.display_address_map();

  
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

      // ---------------------------------------
      // Third test. Write to the shadow.
	  //
      uvm_report_info("TEST", "Checking hardware update...");
	  register_name = "register_map.dual_map.dut3.r2";
	  r = rm.lookup_register_by_name(register_name);
	  r.reset();

	  val_read = r.read_data32();
	  uvm_report_info("TEST", 
	    $psprintf("...         read() -> %x from %s", val_read, register_name));

      uvm_report_info("TEST", "... changing shadow to 'aaa..aa'");
	  r.write_data32(32'haaaaaaaa);
	  val_read = r.read_data32();
	  uvm_report_info("TEST", 
	    $psprintf("...         read() -> %x from %s", val_read, register_name));

      r.backdoor_read(val_read);
	  uvm_report_info("TEST", 
	    $psprintf("...backdoor_read() -> %x from %s", val_read, register_name));
      r.bus_read32(val_read);

      // Pretty print.
      rm.display_address_map();

      uvm_report_info("TEST", "Checking counter register...");
	  register_name = "register_map.dual_map.dut3.r_counter";
	  r = rm.lookup_register_by_name(register_name);

      uvm_report_info("TEST", $psprintf("Register %s = %0x",
	    r.get_full_name(), r.peek_data32()));
	  for(int i = 0; i < 10; i++) begin
		if (i == 5)
		  r.reset();
		else
	      r.write_data32(i);

        uvm_report_info("TEST", $psprintf("Register %s = %0x",
	      r.get_full_name(), r.peek_data32()));
	  end

	  show_register_deprecation_messages();
      global_stop_request();
    endtask
  endclass
endpackage
