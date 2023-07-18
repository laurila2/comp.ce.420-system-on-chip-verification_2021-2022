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

  class device_rf extends uvm_register_file;
    my_regular_register regA;
    my_regular_register regB;

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

  class broadcast_rf extends uvm_register_file;
    uvm_broadcast_register #(bit[31:0]) regA_broadcast;
    uvm_broadcast_register #(bit[31:0]) regB_broadcast;

    function new(string name, uvm_named_object p);
      super.new(name, p);
      // -----------------------
      // Construct the registers
      // -----------------------
      regA_broadcast = new("regA_broadcast", this);
      regB_broadcast = new("regB_broadcast", this);

      // --------------------------------------
      // Add the registers to the register file
      // --------------------------------------
      add_register( regA_broadcast.get_fullname(),    1, regA_broadcast);
      add_register( regB_broadcast.get_fullname(),    2, regB_broadcast);
    endfunction

  endclass

  //
  // The actual register map for this system.
  //
  class my_register_map extends uvm_register_map;
    rand device_rf device1;
    rand device_rf device2;
    rand broadcast_rf broadcast_rf;

    function new(string name, uvm_named_object p);
      super.new(name, p);

      device1 = new("device1", this);
      add_register_file(device1, 'h1000);

      device2 = new("device2", this);
      add_register_file(device2, 'h2000);

      broadcast_rf = new("broadcast", this);
      add_register_file(broadcast_rf, 'h10000);

      broadcast_rf.regA_broadcast.add_target(device1.regA);
      broadcast_rf.regB_broadcast.add_target(device1.regB);

      broadcast_rf.regA_broadcast.add_target(device2.regA);
      broadcast_rf.regB_broadcast.add_target(device2.regB);

    endfunction
  endclass
endpackage
