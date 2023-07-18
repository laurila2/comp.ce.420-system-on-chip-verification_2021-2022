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

package my_registers_pkg;

  import uvm_pkg::*;
  import uvm_register_pkg::*;
  `include "uvm_register_macros.svh"

  // Start of register definitions ---------------------------

  // Define the register bits.
  typedef struct packed {
    bit[1:1] f1; // 1 bit
    bit[2:1] f2; // 2 bits
    bit[3:1] f3; // 3 bits
  } regA_fields_t;

  // Define the register programming abstraction.
  class regA extends uvm_register#(regA_fields_t);
    // Generate the machine that manages fields by name.
    `uvm_register_begin_fields
      `uvm_register_field(f1)
      `uvm_register_field(f2)
      `uvm_register_field(f3)
    `uvm_register_end_fields

    function new(string name, uvm_named_object p);
      super.new(name, p);
      // Initialize the mini-database of reset value, 
      // the access policy, etc.

      // ************
      // Define the permissions by field.
      add_field("f1", 0,          "RW");
      add_field_tag("f1", "TAG1");
      add_field_tag("f1", "RESET1");
      add_field("f2", 'hdeadbeef, "RO");
      add_field_tag("f2", "TAG2");
      add_field("f3", 'h42,       "WO");
      add_field_tag("f3", "TAG3");

      // ************
      // Other ways to do the same thing, BUT field-by-name
      // access is not setup (no mini-database).
      //RMASK = '{'1, '1, '0};
      //WMASK = '{'1, '0, '1};
      //resetValue = '{'0, 'hdeadbeef, 'h42};

      // ************
      // Yet more ways....

      // resetValue = 0;
      // resetValue = '1;

      //   RMASK.f1 = '1;
      //   WMASK.f1 = '1;
      // resetValue.f1 = '0;
  
      //   RMASK.f2 = '1;
      //   WMASK.f2 = '0;
      // resetValue.f2 = 'hdeadbeef;
  
      //   RMASK.f3 = '0;
      //   WMASK.f3 = '1;
      // resetValue.f3 = 'h42;
  
    endfunction
  endclass

  typedef struct packed {
    bit[3:0] f1; // 4 bits
    bit[3:0] f2; // 4 bits
    bit[3:0] f0; // 4 bits
  } regB_fields_t;

  class regB extends uvm_register#(regB_fields_t);
    `uvm_register_begin_fields
      `uvm_register_field(f1)
      `uvm_register_field(f2)
      `uvm_register_field(f0)
    `uvm_register_end_fields

    function new(string name, uvm_named_object p);
      super.new(name, p);
      add_field("f1", 1, "RW");
      add_field_tag("f1", "TAG1");
      add_field_tag("f1", "RESET1");

      add_field("f2", 2, "RO");
      add_field_tag("f2", "TAG2");

      add_field("f0", 3, "WO");
      add_field_tag("f0", "TAG0");
    endfunction
  endclass

  typedef struct packed {
    bit[3:0] f0; // 4 bits
    bit[3:0] f1; // 4 bits
    bit[3:0] f2; // 4 bits
    bit[3:0] f3; // 4 bits
  } regC_fields_t;

  class regC extends uvm_register#(regC_fields_t);
    `uvm_register_begin_fields
      `uvm_register_field(f0)
      `uvm_register_field(f1)
      `uvm_register_field(f2)
      `uvm_register_field(f3)
    `uvm_register_end_fields

    function new(string name, uvm_named_object p);
      super.new(name, p);
      add_field("f0", 0, "RW");
      add_field_tag("f0", "TAG0");

      add_field("f1", 1, "RW");
      add_field_tag("f1", "TAG1");
      add_field_tag("f1", "RESET1");

      add_field("f2", 2, "RW");
      add_field_tag("f2", "TAG2");

      add_field("f3", 3, "RW");
      add_field_tag("f3", "TAG3");
    endfunction
  endclass

  class my_register_file extends uvm_register_file;
    regA A;
    regB B;
    regC C;
    function new(string name, uvm_named_object p);
      super.new(name, p);
      A = new("regA", this);
      B = new("regB", this);
      C = new("regC", this);

      add_register(A.get_full_name(), 'h100, A);
      add_register(B.get_full_name(), 'h200, B);
      add_register(C.get_full_name(), 'h300, C);
    endfunction
  endclass
  // End of register definitions -----------------------------
endpackage 
