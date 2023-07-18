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

  class my_mode1 extends uvm_register #(mode1_fields_t); 
    function new(string name, uvm_named_object p);
      super.new(name, p);
    endfunction
    constraint c { data.f2 > data.f1; }
  endclass
  
  class my_mode2 extends uvm_register #(mode2_fields_t); 
    function new(string name, uvm_named_object p);
      super.new(name, p);
    endfunction
    constraint c { data.f2 == 0; }
  endclass

  //
  // User defined registers.
  //
  class registerA extends uvm_modal_register_derived #(bit[$bits(mode1_fields_t)-1:0]);
    my_mode1 mode1;
    my_mode2 mode2;
  
    function new(string name, uvm_named_object p);
      super.new(name, p);
      mode1 = new("mode1", null);
      mode2 = new("mode2", null);

      add_mode_instance("mode1", mode1);
      add_mode_instance("mode2", mode2);

      assert($bits(mode1_fields_t) == $bits(mode2_fields_t));
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
