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

  //
  // User defined registers.
  //
  class my_regular_register extends uvm_register #(bit[10:0]);
    function new(string name, uvm_named_object p, 
        bit [10:0] l_resetValue = 0);
      super.new(name, p, l_resetValue);
    endfunction
    
    // define the legal (small) values for this register.
    constraint legal_values {
      data > 0;
      data < 10;
    }
  endclass

  typedef struct packed {
    bit [3:0] id;
    bit [10:0] value;
    bit [2:0] incr;
  } counter_fields_t;

  class my_counter_register extends uvm_register #(counter_fields_t);
    function new(string name, uvm_named_object p, 
        bit [31:0] l_resetValue = 0);
      super.new(name, p, l_resetValue);
    endfunction

    // Define the legal state for this register.
    constraint legal_values {
      data.id == data.incr+8;
      //Note: Removed this constraint in favor
      //  of the constraint named 'sub_value'
      //  that is placed in the register file.
      //  data.value > 0; data.value < 500;
      data.incr > 0;
    }
  endclass

  class device_rf extends uvm_register_file;
    rand my_regular_register regA;
    rand my_counter_register regB;

    constraint sub_value {
      regB.data.value == regA.data;
    }

    function new(string name, uvm_named_object p);
      super.new(name, p);
      // -----------------------
      // Construct the registers
      // -----------------------
      regA = new("regA", this);
      regB = new("regB", this);

      // --------------------------------------
      // Add the registers to the register file
      // --------------------------------------
      add_register( regA.get_fullname(),    1, regA);
      add_register( regB.get_fullname(),    2, regB);
    endfunction
  endclass

  //
  // The actual register map for this system.
  //
  class my_register_map extends uvm_register_map;
    rand device_rf device1;
    rand device_rf device2;

    // Make sure the 'incr' field in both counter registers
    // is the same.
    constraint incr_match {
      device1.regB.data.incr == device2.regB.data.incr;
    }
    function new(string name, uvm_named_object p);
      super.new(name, p);

      device1 = new("device1", this);
      add_register_file(device1, 'h1000);

      device2 = new("device2", this);
      add_register_file(device2, 'h2000);
    endfunction
  endclass
endpackage
