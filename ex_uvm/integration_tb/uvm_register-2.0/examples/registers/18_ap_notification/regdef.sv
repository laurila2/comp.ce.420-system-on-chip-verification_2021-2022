//------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//   
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//   
//       http://www.apache.org/licenses/LICENSE-2.0
//   
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------

/* ************************************ */
/* THIS IS AUTOMATICALLY GENERATED CODE */
/* ************************************ */
package my_register_pkg;

  import uvm_pkg::*;
  import uvm_register_pkg::*;

  `include "uvm_macros.svh"
  `include "uvm_register_macros.svh"

// -----------------------------------
// Example 1 - Use "direct" calls from one register to
//             the other when a notification is ready.
//
  class my_regular_register1 extends uvm_register #(bit[31:0]);
    my_regular_register1 r[$]; // TODO: uvm_register_base??

    // ---------------------------
    // Library code
    function void add_triggered(my_regular_register1 l_r);
      r.push_back(l_r);
    endfunction

    function void write(T v, T local_mask = '1);
      foreach (r[i])
        r[i].write_direct(v);
      super.write(v, local_mask);
    endfunction

    function string convert2string();
      return $psprintf("%0x", peek());
    endfunction
    // ---------------------------
    // User code 
    function new(string name, uvm_named_object p, 
        bit [31:0] l_resetValue = 0);
      super.new(name, p, l_resetValue);
    endfunction

    // Implement a function in the target which
    // get called when something "of interest" happens.
    function void write_direct(T v);
      write(v+10);
      uvm_report_info("write_direct", 
        $psprintf("Setting %s to %s", 
          get_full_name(),
          convert2string()));
    endfunction
  endclass

// -----------------------------------
// Example 2 - Use an analysis port, doing the .connect(), etc
//             that is normally done. A register notifies
//             another register by just calling ap.write().
//
  //`UVM_REGISTER_NOTIFY(_notify)
  //`UVM_REGISTER_NOTIFY(_generic_notify)
  `UVM_REGISTER_NOTIFY(_XXX)
  `UVM_REGISTER_NOTIFY(_generic_XXX)

  class my_regular_register2 extends uvm_register #(bit[31:0]);
    // ---------------------------
    // Library code

    // This macro causes the following line of code to
    //  be generated.
    // `USE_NOTIFY(_notify, my_regular_register2) 
    //uvm_register_notify_notify 
    //  #(this_type, my_regular_register2) analysis_export_notify;
	//uvm_analysis_imp_nc #(this_type, 
	  //my_regular_register2) analysis_export_XXX;
    `USE_NOTIFY(_XXX, my_regular_register2) 

    // This macro causes the following line of code to
    //  be generated.
    // `USE_NOTIFY(_generic_notify, my_regular_register2) 
    //uvm_register_notify_generic_notify 
    //  #(uvm_register_base, my_regular_register2) 
    //    analysis_export_generic_notify;
	//uvm_analysis_imp_nc #(uvm_register_base, 
	  //my_regular_register2) analysis_export_generic_XXX;
    `USE_GENERIC_NOTIFY(_generic_XXX, my_regular_register2) 

    function string convert2string();
      return $psprintf("%0x", peek());
    endfunction
    // ---------------------------
    // User code 
    function new(string name, uvm_named_object p, 
        bit [31:0] l_resetValue = 0);
      super.new(name, p, l_resetValue);

      // ------------
      // Library code
      // analysis_export_notify = new(
      //   {get_full_name(), ".analysis_export_notify"}, this);
      // analysis_export_generic_notify = new(
      //   {get_full_name(), ".analysis_export_generic_notify"}, 
      //     this);
      analysis_export_XXX = new(
         {get_full_name(), ".analysis_export"}, this);
      analysis_export_generic_XXX = new(
         {get_full_name(), ".analysis_export_generic"}, 
          this);
    endfunction

    // Implemented by the user.
    function void write_XXX(this_type t);
      write(t.peek()+1);
      uvm_report_info("write_XXX", 
        $psprintf("Setting %s to %s", 
          get_full_name(),
          convert2string()));
    endfunction

    // Implemented by the user.
    function void write_generic_XXX(uvm_register_base t);
      write(t.peek_data32()+1);
      uvm_report_info("write_generic_XXX", 
        $psprintf("Setting %s to %s", 
          get_full_name(),
          convert2string()));
    endfunction
    // Implemented by the user.
    function void write_notify(this_type t);
      write(t.peek()+1);
      uvm_report_info("write_notify", 
        $psprintf("Setting %s to %s", 
          get_full_name(),
          convert2string()));
    endfunction

    // Implemented by the user.
    function void write_generic_notify(uvm_register_base t);
      write(t.peek_data32()+1);
      uvm_report_info("write_generic_notify", 
        $psprintf("Setting %s to %s", 
          get_full_name(),
          convert2string()));
    endfunction
  endclass

  class device1_rf extends uvm_register_file;
    my_regular_register1 regA;
    my_regular_register1 regA_follower;

    function new(string name, uvm_named_object p);
      super.new(name, p);
      // -----------------------
      // Construct the registers
      // -----------------------
      regA = new("regA", this);
      regA_follower = new("regA_follower", this);

      // --------------------------------------
      // Add the registers to the register file
      // --------------------------------------
      add_register( regA.get_fullname(),    1, regA);
      add_register( regA_follower.get_fullname(),    
                                            2, regA_follower);
    endfunction

    function void connect();
	  // Sort of a "connect"
      regA.add_triggered(regA_follower);
	endfunction
  endclass

  class device2_rf extends uvm_register_file;
    my_regular_register2 regA;
    my_regular_register2 regA_follower;

    function new(string name, uvm_named_object p);
      super.new(name, p);
      // -----------------------
      // Construct the registers
      // -----------------------
      regA = new("regA", this);
	  regA.build_ap();
      regA_follower = new("regA_follower", this);

      // --------------------------------------
      // Add the registers to the register file
      // --------------------------------------
      add_register( regA.get_fullname(),    1, regA);
      add_register( regA_follower.get_fullname(),    
                                            2, regA_follower);
    endfunction

    function void connect();
      //regA.write_ap.connect(
      //  regA_follower.analysis_export_notify);
      //regA.generic_write_ap.connect(
      //  regA_follower.analysis_export_generic_notify);
      regA.write_ap.connect(
        regA_follower.analysis_export_XXX);
      regA.generic_write_ap.connect(
        regA_follower.analysis_export_generic_XXX);
    endfunction
  endclass

  // The actual register map for this system.
  //
  class my_register_map extends uvm_register_map;
    rand device1_rf device1;
    rand device2_rf device2;

    function new(string name, uvm_named_object p);
      super.new(name, p);

      device1 = new("device1", this);
      device1.connect();
      add_register_file(device1, 'h1000);

      device2 = new("device2", this);
      device2.connect();
      add_register_file(device2, 'h2000);
    endfunction
  endclass
endpackage
