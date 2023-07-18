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

  class my_coherent_master extends uvm_coherent_register_master #(bit[31:0]);
    function new(string name, uvm_named_object p);
      super.new(name, p);
    endfunction
  endclass

  class my_coherent_slave extends uvm_coherent_register_slave #(bit[31:0]);
    function new(string name, uvm_named_object p);
      super.new(name, p);
    endfunction
  endclass

  class device_rf extends uvm_register_file;
    my_coherent_master m;
    my_coherent_slave slaves[8];

    function new(string name, uvm_named_object p);
      super.new(name, p);
      // -----------------------
      // Construct the registers
      // -----------------------
	  m = new("master", this);
	  foreach (slaves[i]) begin
	    name = $psprintf("slave%0d", i);
	    slaves[i] = new(name, this);
	    m.add_slave(slaves[i]);
	  end

      // --------------------------------------
      // Add the registers to the register file
      // --------------------------------------
      add_register( m.get_fullname(),    1, m);
	  foreach (slaves[i])
        add_register( slaves[i].get_fullname(), 2+i, slaves[i]);
    endfunction
  endclass

  //
  // The actual register map for this system.
  //
  class my_register_map extends uvm_register_map;
    rand device_rf device1;
    rand device_rf device2;

    function new(string name, uvm_named_object p);
      super.new(name, p);

      device1 = new("device1", this);
      add_register_file(device1, 'h1000);

      device2 = new("device2", this);
      add_register_file(device2, 'h2000);
    endfunction
  endclass
endpackage
