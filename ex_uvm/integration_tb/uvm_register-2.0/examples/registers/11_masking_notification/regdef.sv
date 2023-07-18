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
    bit rw0;       // Read-Write
    bit rw;        // Read-Write
    bit ro;        // Read-Only
    bit wo;        // Write-Only
    bit w1clr;     // Write 1 will write a 0.
    bit w0set;     // Write 0 will write a 1.
    bit clronread; // Clear-on-Read
    bit setonread; // Set-on-Read
  } fields_t;

  //
  // User defined registers.
  //
  class my_regular_register extends uvm_register #(fields_t);
    function new(string name, uvm_named_object p, 
        bit [31:0] l_resetValue = 0);
      super.new(name, p, l_resetValue);

      // `set_field(rw0, RW)
      RMASK.rw0 = '1; WMASK.rw0 = '1;

      // `set_field(rw,  RW)
      RMASK.rw  = '1; WMASK.rw  = '1;

      // `set_field(ro,  RO)
      RMASK.ro  = '1; WMASK.ro  = '0;

      //----------------------------------------
      // Set the RMASK using certain techniques.
      //----------------------------------------
      //
      // 1. The old-fashioned way. Error prone.
      //     RMASK &= 'b11101111;
      //
      // 2. The FULL struct way. Need to know everything at 
      //    the same time. All fields get assigned at once.
      //
      // RMASK     = 
      //  '{rw0:'1, rw:'1, ro:'1, wo:'0, w1clr:'1, w0set:'1, clronread:'1, setonread:'1};
      //
      // 3. The direct programming way. Typing is good.
      //
      RMASK.wo  = '0;
      //
      // 4. The New New Way. A MACRO! Let the macro 
      //    do the typing.
      //      `set_field(wo,  WO)
      //----------------------------------------

      WMASK.wo  = '1;
      // WMASK     = 
      //  '{rw0:'1, rw:'1, ro:'0, wo:'1, w1clr:'1, w0set:'1, clronread:'1, setonread:'1};

      // `set_field(w1clr, W1CLRMASK)
      W1CLRMASK.w1clr = '1;
      //W1CLRMASK = 
      //  '{rw0:'0, rw:'0, ro:'0, wo:'0, w1clr:'1, w0set:'0, clronread:'0, setonread:'0};

      // `set_field(w0set, W0SETMASK)
      W0SETMASK.w0set = '1;
      //W0SETMASK = 
      //  '{rw0:'0, rw:'0, ro:'0, wo:'0, w1clr:'0, w0set:'1, clronread:'0, setonread:'0};

      // `set_field(clronread, CLRONREAD)
      CLRONREAD.clronread = '1;
      //CLRONREAD = 
      //  '{rw0:'0, rw:'0, ro:'0, wo:'0, w1clr:'0, w0set:'0, clronread:'1, setonread:'0};

      // `set_field(setonread, SETONREAD)
      SETONREADMASK.setonread = '1;
      //SETONREADMASK = 
      //  '{rw0:'0, rw:'0, ro:'0, wo:'0, w1clr:'0, w0set:'0, clronread:'0, setonread:'1};
    endfunction

    function string convert2string();
      return $psprintf("%0x", peek());
    endfunction

    function uvm_object clone();
      my_regular_register r = new(get_name(), null);
      r.set_reset_value(resetValue);
      r.copy(this);
      return r;
    endfunction
  endclass

  class device1_rf extends uvm_register_file;
    rand my_regular_register REGA;
    rand my_regular_register REGA_ro;

    function uvm_object clone();
      device1_rf my_clone;
      my_clone = new({"clone.", get_full_name()}, null);
      $cast(my_clone.REGA, REGA.clone());
	  //RICH REGA.set_parent(my_clone);
      return my_clone;
    endfunction

    function new(string name, uvm_named_object p);
      super.new(name, p);
      // -----------------------
      // Construct the registers
      // -----------------------
      REGA = new("REGA", this);
      REGA.set_reset_value('hdeadbeef);
      REGA_ro = new("REGA_ro", this);
      REGA_ro.set_actual_register(REGA);
      REGA_ro.RMASK = '1; // Tada! Readable
      REGA_ro.WMASK = '0; // Tada! Read-Only

      uvm_top.set_config_object("*", "A",    REGA);
      uvm_top.set_config_object("*", "A_ro", REGA_ro);

      // --------------------------------------
      // Add the registers to the register file
      // --------------------------------------
      add_register( REGA.get_fullname(), 16, REGA);
      add_register( REGA_ro.get_fullname(), 17, REGA_ro);
    endfunction
  endclass

  class device2_rf extends uvm_register_file;
    rand my_regular_register REGB;
    rand my_regular_register REGC;
    int base = 16;

    function uvm_object clone();
      device2_rf my_clone;
      my_clone = new({"clone.", get_full_name()}, null);
      $cast(my_clone.REGB, REGB.clone());
      $cast(my_clone.REGC, REGC.clone());
      my_clone.base = base;
      return my_clone;
    endfunction

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

    function uvm_object clone();
      my_register_map my_clone;
      my_clone = new({"clone.", get_full_name()}, null);
      $cast(my_clone.device1, device1.clone());
      $cast(my_clone.device2, device2.clone());
      return my_clone;
    endfunction

    function new(string name, uvm_named_object p);
      super.new(name, p);

      device1 = new("device1", this);
      add_register_file(device1, 'h1000);

      device2 = new("device2", this);
      add_register_file(device2, 'h2000);
    endfunction
  endclass
endpackage
