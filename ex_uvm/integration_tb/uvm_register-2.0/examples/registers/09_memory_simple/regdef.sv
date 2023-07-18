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
  class my_regular_register extends uvm_register #(bit[31:0]);
    function new(string name, uvm_named_object p, 
        bit [31:0] l_resetValue = 0);
      super.new(name, p, l_resetValue);
    endfunction

    function string convert2string();
      return $psprintf("%0x", peek());
    endfunction
  endclass

  class my_id_register extends uvm_id_register #(bit[31:0]);
    function new(string name, uvm_named_object p, 
        bit[31:0] new_values[]);
      super.new(name, p, new_values);
    endfunction
  endclass

  // See http://en.wikipedia.org/wiki/Endianess
  class my_memory_little extends uvm_memory#(bit[31:0]);
    function new(string name, uvm_named_object p, 
        bit [31:0] l_resetValue = 0);
      super.new(name, p, l_resetValue);
    endfunction
  endclass

  class my_memory_big extends uvm_memory#(bit[0:31]);
    function new(string name, uvm_named_object p, 
        bit [0:31] l_resetValue = 0);
      super.new(name, p, l_resetValue);
    endfunction
  endclass

  //
  // My devices ALWAYS have an id register.
  //
  class my_device extends uvm_register_file;
    my_id_register id;

    function new(string name, uvm_named_object p);
      super.new(name, p);
      // Don't construct the id register here,
      // since we need to know how many items
      // it has to properly build our covergroup.
      // Construct it in the place where we know
      // the items.
    endfunction
  endclass

  class device1_rf extends my_device;
    rand my_regular_register REGA;

    bit[31:0] id_values[] = '{1, 2, 3, 4};

    function new(string name, uvm_named_object p);
      super.new(name, p);
      // -----------------------
      // Construct the registers
      // -----------------------
      id   = new("ID", this, id_values); 
      REGA = new("REGA", this, 'hdeadbeef);

      // --------------------------------------
      // Add the registers to the register file
      // --------------------------------------
      add_register( id.get_fullname(),    1, id);
      add_register( REGA.get_fullname(), 16, REGA);

    endfunction
  endclass

  class device2_rf extends my_device;
    rand my_regular_register REGB;
    rand my_regular_register REGC;
    rand my_memory_little    mem_little;
    rand my_memory_big       mem_big;
    int base = 16;

    bit[31:0] id_values[] = '{9, 10, 11, 12, 13, 14, 15};

    function new(string name, uvm_named_object p);
      super.new(name, p);
      // -----------------------
      // Construct the registers
      // -----------------------
      id   = new("ID", this, id_values); 

      REGB = new("REGB", this, 'hBbeef);
      REGC = new("REGC", this, 'hCbeef);
      mem_little = new("mem_little",  this, 'h12345678);
      mem_big    = new("mem_big",     this, 'h12345678);

      // --------------------------------------
      // Add the registers to the register file
      // --------------------------------------
      add_register( id.get_fullname(),    1, id);
      for(int i = 0; i < 8; i++) begin
        add_register( REGB.get_fullname(), base+i*2,   REGB);
        add_register( REGC.get_fullname(), base+i*2+1, REGC);
      end
      add_memory(mem_little.get_fullname(), 
        'h10000, 'h80000, mem_little);
      add_memory(mem_big.get_fullname(),    
        'h90000, 'ha0000, mem_big);
    endfunction
  endclass

  //
  // The actual register map for this system.
  //
  class my_register_map extends uvm_register_map;
    rand device1_rf device1;
    rand device2_rf device2;

    function new(string name, uvm_named_object p);
      super.new(name, p);

      device1 = new("device1", this);
      add_register_file(device1, 'h1000);

      device2 = new("device2", this);
      add_register_file(device2, 'h2000);
    endfunction
  endclass
endpackage
