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

package stopwatch_register_pkg;

  import uvm_pkg::*;
  import uvm_register_pkg::*;

  typedef bit[31:0] bit32_t;

  typedef struct packed {
    bit [31:7] padding;
    bit [3:0] stride;
    bit updown;
    bit upper_limit_reached;
    bit lower_limit_reached;
  } stopwatch_csr_t;

  class stopwatch_value extends uvm_register #(bit32_t);
    function new(string name, uvm_named_object p, 
        bit32_t resetVal = 0);
      super.new(name, p, resetVal);
      // READ-ONLY under normal circumstances.
      WMASK = 'b0;
    endfunction
  endclass

  class stopwatch_reset_value extends uvm_register #(bit32_t);
    function new(string name, uvm_named_object p, 
        bit32_t resetVal = 0);
      super.new(name, p, resetVal);
    endfunction
  endclass

  class stopwatch_upper_limit extends uvm_register #(bit32_t);
    function new(string name, uvm_named_object p);
      super.new(name, p);
    endfunction
  endclass

  class stopwatch_lower_limit extends uvm_register #(bit32_t);
    function new(string name, uvm_named_object p);
      super.new(name, p);
    endfunction
  endclass

  class stopwatch_csr extends uvm_register #(stopwatch_csr_t);

    covergroup c;
                  stride: coverpoint data.stride; 
                  updown: coverpoint data.updown; 
     upper_limit_reached: coverpoint data.upper_limit_reached;
     lower_limit_reached: coverpoint data.lower_limit_reached;
    endgroup

    function void sample();
      c.sample();
    endfunction

    function new(string name, uvm_named_object p);
      super.new(name, p);
      c = new();
      // All bits writable, except the "limits-reached" bits.
      WMASK = 'b1111_1_0_0;
    endfunction
  endclass

  class stopwatch_memory extends uvm_register #(bit32_t);
    function new(string name, uvm_named_object p);
      super.new(name, p);
    endfunction
  endclass

  class stopwatch_register_file extends uvm_register_file;

    rand stopwatch_value       stopwatch_value_reg;

    rand stopwatch_reset_value stopwatch_reset_value_reg;
    rand stopwatch_upper_limit stopwatch_upper_limit_reg;
    rand stopwatch_lower_limit stopwatch_lower_limit_reg;

    rand stopwatch_csr         stopwatch_csr_reg;

    rand stopwatch_memory      stopwatch_memory_reg[8];

    function new(string name, uvm_named_object p);
      super.new(name, p);
      uvm_report_info("stopwatch_register_file", "new()");

      // -----------------------
      // Construct the registers
      // -----------------------
      stopwatch_value_reg       = new("VALUE", this);
      // 2.0 PORT stopwatch_reset_value_reg = new("RESET_VALUE", this, 
      // 2.0 PORT   'hdeadbeef);
      // 2.0 PORT stopwatch_reset_value_reg = new("RESET_VALUE", this);
	  // 2.0 PORT stopwatch_reset_value_reg.set_reset_value('hdeadbeef);
// 2.0 PORT UVM_INFO @ 0: reporter [ResetValueInConstructor] Register register_map.sw1.RESET_VALUE sets a reset value in the constructor argument
      stopwatch_reset_value_reg = new("RESET_VALUE", this);
	  stopwatch_reset_value_reg.set_reset_value('hdeadbeef);
      stopwatch_upper_limit_reg = new("UPPER_LIMIT", this);
      stopwatch_lower_limit_reg = new("LOWER_LIMIT", this);
      stopwatch_csr_reg         = new("CSR", this);

      foreach ( stopwatch_memory_reg[i] )
          stopwatch_memory_reg[i] = 
            new( $psprintf("MEM[%0d]", i), this);
        
      // --------------------------------------
      // Add the registers to the register file
      // --------------------------------------
      add_register(
        stopwatch_value_reg.get_fullname(),
        1, stopwatch_value_reg);
      add_register(
        stopwatch_reset_value_reg.get_fullname(),
        2, stopwatch_reset_value_reg);
      add_register(
        stopwatch_upper_limit_reg.get_fullname(),
        3, stopwatch_upper_limit_reg);
      add_register(
        stopwatch_lower_limit_reg.get_fullname(),
        4, stopwatch_lower_limit_reg);

      add_register(
        stopwatch_csr_reg.get_fullname(),
        5, stopwatch_csr_reg);

      add_register(
        stopwatch_memory_reg[0].get_fullname(),
        6, stopwatch_memory_reg[0]);  
      add_register(
        stopwatch_memory_reg[1].get_fullname(),
        7, stopwatch_memory_reg[1]);  
      add_register(
        stopwatch_memory_reg[2].get_fullname(),
        8, stopwatch_memory_reg[2]);  
      add_register(
        stopwatch_memory_reg[3].get_fullname(),
        9, stopwatch_memory_reg[3]);  
      add_register(
        stopwatch_memory_reg[4].get_fullname(),
        10, stopwatch_memory_reg[4]);  
      add_register(
        stopwatch_memory_reg[5].get_fullname(),
        11, stopwatch_memory_reg[5]);  
      add_register(
        stopwatch_memory_reg[6].get_fullname(),
        12, stopwatch_memory_reg[6]);  
      add_register(
        stopwatch_memory_reg[7].get_fullname(),
        13, stopwatch_memory_reg[7]);  
    endfunction
  endclass


  //
  // The actual register map for this system.
  //
  class stopwatch_register_map extends uvm_register_map;
    rand stopwatch_register_file sw1;
    rand stopwatch_register_file sw2;

    function new(string name, uvm_named_object p);
      super.new(name, p);
      uvm_report_info("stopwatch_register_map", "new()");

      sw1 = new("sw1", this);
      sw2 = new("sw2", this);

      add_register_file(sw1, 'h1000);
      add_register_file(sw2, 'h2000);
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

      stopwatch_register_map register_map;

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
