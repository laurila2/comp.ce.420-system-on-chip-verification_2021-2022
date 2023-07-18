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

  class my_fifo_register extends 
      uvm_fifo_register #(bit[31:0]);
    function new(string name, uvm_named_object p);
      super.new(name, p);
    endfunction
  endclass

  //
  // My devices ALWAYS have an fifo register.
  //
  class my_device extends uvm_register_file;
    my_fifo_register fifo;

    function new(string name, uvm_named_object p);
      super.new(name, p);
      // -----------------------
      // Construct the registers
      // -----------------------
      fifo   = new("FIFO", this); 
      add_register( fifo.get_fullname(),    1, fifo);
    endfunction
  endclass

  class device1_rf extends my_device;
    rand my_regular_register REGA;

    function new(string name, uvm_named_object p);
      super.new(name, p);
      // -----------------------
      // Construct the registers
      // -----------------------
      REGA = new("REGA", this);
	  REGA.set_reset_value('hdeadbeef);

      // --------------------------------------
      // Add the registers to the register file
      // --------------------------------------
      add_register( REGA.get_fullname(), 16, REGA);
    endfunction
  endclass

  class device2_rf extends my_device;
    rand my_regular_register REGB;
    rand my_regular_register REGC;
    int base = 16;

    function new(string name, uvm_named_object p);
      super.new(name, p);
      // -----------------------
      // Construct the registers
      // -----------------------
      REGB = new("REGB", this);
      REGB.set_reset_value('hBbeef);
      REGC = new("REGC", this);
      REGC.set_reset_value('hCbeef);

      // --------------------------------------
      // Add the registers to the register file
      // --------------------------------------
      for(int i = 0; i < 8; i++) begin
        add_register( REGB.get_fullname(), base+i*2,   REGB);
        add_register( REGC.get_fullname(), base+i*2+1, REGC);
      end
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
