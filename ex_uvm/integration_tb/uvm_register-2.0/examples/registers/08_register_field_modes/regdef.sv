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

  typedef struct packed {
    bit [0:1]f1;
    bit [0:1]f2;
  } mode1_fields_t;
  
  typedef struct packed {
    bit [0:2]f1;
    bit [0:0]f2;
  } mode2_fields_t;

  typedef union packed { 
    mode1_fields_t m1;
    mode2_fields_t m2;
  } registerA_fields_t;

  //
  // User defined registers.
  //
  class registerA extends uvm_modal_register #(registerA_fields_t); 
    function new(string name, uvm_named_object p);
      super.new(name, p);
      add_mode("mode1");
      add_mode("mode2");
    endfunction

    constraint c_mode1 { data.m1.f2 > data.m1.f1; }
    constraint c_mode2 { data.m2.f2 == 0; }

    function void set_mode(string mode);
      super.set_mode(mode);
      // When we switch modes, turn off 
      // coverage for certain modes.
      // ....

      // When we switch modes, turn off 
      // constraints for certain modes.
      c_mode1.constraint_mode(0);
      c_mode2.constraint_mode(0);
      case(mode)
        "mode1": c_mode1.constraint_mode(1);
        "mode2": c_mode2.constraint_mode(1);
      endcase
    endfunction
  endclass
  
  class my_device extends uvm_register_file;
    function new(string name, uvm_named_object p);
      super.new(name, p);
    endfunction
  endclass

  class device1_rf extends my_device;
    rand registerA REGA_1;
    rand registerA REGA_2;
    rand registerA REGA_3;

    function new(string name, uvm_named_object p);
      super.new(name, p);
      // -----------------------
      // Construct the registers
      // -----------------------
      REGA_1 = new("REGA_1", this);
      REGA_2 = new("REGA_2", this);
      REGA_3 = new("REGA_3", this);

      // --------------------------------------
      // Add the registers to the register file
      // --------------------------------------
      add_register( REGA_1.get_fullname(), 1, REGA_1);
      add_register( REGA_2.get_fullname(), 2, REGA_2);
      add_register( REGA_3.get_fullname(), 3, REGA_3);

      add_register( REGA_1.get_fullname(), 'h101, REGA_1);
      add_register( REGA_2.get_fullname(), 'h102, REGA_2);
      add_register( REGA_3.get_fullname(), 'h103, REGA_3);

    endfunction
  endclass

  //
  // The actual register map for this system.
  //
  class my_register_map extends uvm_register_map;
    rand device1_rf device1;

    function new(string name, uvm_named_object p);
      super.new(name, p);

      device1 = new("device1", this);
      add_register_file(device1, 'h1000);
    endfunction
  endclass
endpackage
