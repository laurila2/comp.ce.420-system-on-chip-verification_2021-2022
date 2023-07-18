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
  `include "uvm_macros.svh"

  // Start of register definitions ---------------------------

  class regA extends uvm_register#(bit[31:0]);
    function new(string name, uvm_named_object p);
      super.new(name, p);
    endfunction
  endclass

  class regB extends uvm_register#(bit[31:0]);
    function new(string name, uvm_named_object p);
      super.new(name, p);
    endfunction
  endclass

  class regID extends uvm_register#(bit[31:0]);
    function new(string name, uvm_named_object p);
      super.new(name, p);
    endfunction
  endclass

  // Start of register file definitions ---------------------------
  class rf_ew extends uvm_register_file;
    regA A, A_slow;
    regB B;
    `uvm_get_type_name_func(rf_ew)
    function new(string name, uvm_named_object p);
      super.new(name, p);
      A = new("regA", this);
      A_slow = new("regA_slow", this);
      B = new("regB", this);
      add_register(A.get_full_name(), 'h0, A);
      add_register(A.get_full_name(), 'h1, A);
      add_register(A.get_full_name(), 'h2, A);
      add_register(A_slow.get_full_name(), 'h3, A_slow);
      add_register(B.get_full_name(), 'h4, B);
    endfunction
  endclass

  class rf_ns extends uvm_register_file;
    rf_ew east, west;
    `uvm_get_type_name_func(rf_ns)
    function new(string name, uvm_named_object p);
      super.new(name, p);
      west = new("west", this);
      east = new("east", this);
      add_register_file(west, 'h10);
      add_register_file(east, 'h20);
    endfunction
  endclass

  class dut extends uvm_register_file;
    rf_ns north, south;
    regID id;
    `uvm_get_type_name_func(dut)
    function new(string name, uvm_named_object p);
      super.new(name, p);
      north = new("north", this);
      south = new("south", this);
      id = new("regID", this);
      add_register(id.get_full_name(), 'h0, id);
      add_register_alias(id, "myID");

      add_register_file(north, 'h100);
      add_register_file(south, 'h200);
    endfunction
  endclass

  // Start of register map definitions ---------------------------
  class AXI extends uvm_register_map;
    dut dut1, dut2; 
    regID id;

    `uvm_get_type_name_func(AXI)

    function uvm_register_container get_rmb(string name);
      uvm_register_container rmb;
      uvm_object o;
      if (uvm_top.get_config_object(name, o, 0))
        $cast(rmb, o);
      return rmb;
    endfunction

    function new(string name, uvm_named_object p);
      super.new(name, p);

      id = new("regID", this);
      add_register(id.get_full_name(), 'h0, id);
      add_register_alias(id, "myID");

      if (!$cast(dut1, get_rmb("dut1")))
        uvm_report_fatal("AXI", "No dut1");

      begin
        uvm_object o;
        if (uvm_top.get_config_object("dut2", o, 0))
          $cast(dut2,o);
        else 
          uvm_report_fatal("AXI", "No dut2");
      end
      add_register_file(dut1, 'h10000);
      add_register_file(dut1, 'h12000);
      add_register_file(dut2, 'h20000);
      add_register_file(dut2, 'h22000);
    endfunction
  endclass

  class AHB extends uvm_register_map;
    dut dut1, dut2; 
    regID id;

    `uvm_get_type_name_func(AHB)
    function new(string name, uvm_named_object p);
      super.new(name, p);

      id = new("regID", this);
      add_register(id.get_full_name(), 'h0, id);
      add_register_alias(id, "myID");

      begin
        uvm_object o;
        if (uvm_top.get_config_object("dut1", o, 0))
          $cast(dut1,o);
        else 
          uvm_report_fatal("AXI", "No dut1");
        if (uvm_top.get_config_object("dut2", o, 0))
          $cast(dut2,o);
        else 
          uvm_report_fatal("AXI", "No dut2");
      end
      add_register_file(dut1, 'h10000);
      add_register_file(dut1, 'h11000);
      add_register_file(dut2, 'h20000);
      add_register_file(dut2, 'h21000);
    endfunction
  endclass

  class USB extends uvm_register_map;
    dut dut1, dut2;
    regID id;

    `uvm_get_type_name_func(USB)
    function new(string name, uvm_named_object p);
      super.new(name, p);

      id = new("regID", this);
      add_register(id.get_full_name(), 'h0, id);
      add_register_alias(id, "myID");

      begin
        uvm_object o;
        if (uvm_top.get_config_object("dut1", o, 0))
          $cast(dut1,o);
        else 
          uvm_report_fatal("AXI", "No dut1");
        if (uvm_top.get_config_object("dut2", o, 0))
          $cast(dut2,o);
        else 
          uvm_report_fatal("AXI", "No dut2");
      end
      add_register_file(dut1, 'h10000);
      add_register_file(dut2, 'h20000);
    endfunction
  endclass

  class internal extends uvm_register_map;
    AXI axi;
    AHB ahb;
    `uvm_get_type_name_func(internal)
    function new(string name, uvm_named_object p);
      super.new(name, p);
      axi = new("axi", this);
      ahb = new("ahb", this);
      add_register_file(axi, 'h300000);
      add_register_file(ahb, 'h400000);

      // Each mapping creates an "instance" - a mapping which has
      // had it's addresses "fixed". This instance needs a unique
      // name if you want to refer to it by name.
      // These mappings are aliases.
      add_register_file(axi, 'h600000);
      add_register_file(axi, 'h700000);
      add_register_file(ahb, 'h800000);
      add_register_file(ahb, 'h900000);
    endfunction
  endclass

  class external extends uvm_register_map;
    USB usb;
    `uvm_get_type_name_func(external)
    function new(string name, uvm_named_object p);
      super.new(name, p);
      usb = new("usb", this);
      add_register_file(usb, 'h500000);
    endfunction
  endclass

  class system_map extends uvm_register_map;
    dut dut1, dut2; 
    internal i;
    external e;
    `uvm_get_type_name_func(system_map)
    function new(string name, uvm_named_object p);
      super.new(name, p);

      dut1 = new("dut1", this);
      set_config_object("*", "dut1", dut1, 0);

      dut2 = new("dut2", this);
      set_config_object("*", "dut2", dut2, 0);

      i = new("internal", this);
      e = new("external", this);
      add_register_file(i, 'h0);
      add_register_file(e, 'h0);
    endfunction
  endclass
endpackage 
