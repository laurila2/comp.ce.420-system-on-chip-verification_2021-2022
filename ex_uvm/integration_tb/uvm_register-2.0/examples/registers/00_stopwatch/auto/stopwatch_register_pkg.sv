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
  `include "uvm_register_macros.svh"

  typedef bit[31:0] bit32_t;

  typedef struct packed {
    bit [31:7] padding;
    bit [3:0] stride;
    bit updown;
    bit upper_limit_reached;
    bit lower_limit_reached;
  } stopwatch_csr_t;

  class stopwatch_value extends uvm_register #(bit32_t);
    function new(string name, uvm_named_object p);
      super.new(name, p);
      // READ-ONLY under normal circumstances.
      WMASK = 'b0;
    endfunction
  endclass

  class stopwatch_reset_value extends uvm_register #(bit32_t);
    function new(string name, uvm_named_object p);
      super.new(name, p);
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

`ifndef BETA7
    `uvm_register_begin_fields
      `uvm_register_field(stride)
      `uvm_register_field(updown)
      `uvm_register_field(upper_limit_reached)
      `uvm_register_field(lower_limit_reached)
    `uvm_register_end_fields 
`endif

    function new(string name, uvm_named_object p);
      super.new(name, p);
      c = new();

      uvm_report_info("stopwatch_register", "new()");
      // All bits writable, except the "limits-reached" bits.
`ifdef BETA7
      WMASK = 'b1111_1_0_0;
`else
      add_field("stride",              0, "RW");
      add_field("updown",              0, "RW");
      add_field("upper_limit_reached", 0, "RO");
      add_field("lower_limit_reached", 0, "RO");

      //print_fields();
`endif
    endfunction

    function string convert2string();
`ifdef INCA
      return $psprintf("CSR: (%x) (%x %x %x %x)", 
`else
      return $psprintf("CSR: (%p) (%x %x %x %x)", 
`endif
        data, 
        data.stride, 
        data.updown, 
        data.upper_limit_reached, 
        data.lower_limit_reached);
    endfunction
  endclass

  class stopwatch_memory extends uvm_register #(bit32_t);
    function new(string name, uvm_named_object p);
      super.new(name, p);
    endfunction
  endclass

  class stopwatch_register_file extends uvm_register_file;

    stopwatch_value       stopwatch_value_reg;

    stopwatch_reset_value stopwatch_reset_value_reg;
    stopwatch_upper_limit stopwatch_upper_limit_reg;
    stopwatch_lower_limit stopwatch_lower_limit_reg;

    stopwatch_csr         stopwatch_csr_reg;

    stopwatch_memory      stopwatch_memory_reg[8];

    function new(string name, uvm_named_object p);
      super.new(name, p);
      uvm_report_info("stopwatch_register_file", "new()");

      // -----------------------
      // Construct the registers
      // -----------------------
      stopwatch_value_reg       = new("VALUE", this);
      stopwatch_reset_value_reg = new("RESET_VALUE", this);
      stopwatch_upper_limit_reg = new("UPPER_LIMIT", this);
      stopwatch_lower_limit_reg = new("LOWER_LIMIT", this);
      stopwatch_csr_reg         = new("CSR", this);

      foreach ( stopwatch_memory_reg[i] ) begin
          stopwatch_memory_reg[i] = 
            new( $psprintf("MEM[%0d]", i), this);
      end
        
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
    stopwatch_register_file sw1;
    stopwatch_register_file sw2;

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
