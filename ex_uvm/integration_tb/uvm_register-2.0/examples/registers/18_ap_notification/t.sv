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

import uvm_pkg::*;
import uvm_register_pkg::*;
import my_register_pkg::*;

/*
 * Simple test.
 *
 * Instantiate the registers, register map and register file.
 * Print the address map.
 * Write the register. 
 */
class uvm_named_object_top_class extends uvm_named_object;
  function new(string name, uvm_named_object p);
    super.new(name, p);
  endfunction
endclass
uvm_named_object_top_class uvm_named_object_top = new("__top__", null);

class env extends uvm_env;
  my_register_map rm;
  uvm_register_base r;

  function new(string name, uvm_component p);
    super.new(name, p);
  endfunction

  function void build();
    rm = new("rm", uvm_named_object_top);
  endfunction

  task run();
    rm.display_address_map();
    $display("---------------------------");
    $display( " Test: AP Notification");

    //$cast(r, rm.lookup_register_by_name("e.rm.device1.regA"));
    $cast(r, rm.lookup_register_by_name(".rm.device1.regA"));
    $display("...Setting register %s",
      r.get_full_name());
    r.write_data32('h42);

    // Print the address map
    rm.display_address_map();

    //$cast(r, rm.lookup_register_by_name("e.rm.device2.regA"));
    $cast(r, rm.lookup_register_by_name(".rm.device2.regA"));
    $display("...Setting register %s",
      r.get_full_name());
    r.write_data32('h42);

    $display("---------------------------");
    $display( " Test: Final Values");

    // Print the address map
    rm.display_address_map();

    uvm_top.stop_request();
  endtask
endclass
module top;
 env e = new("e", null);
 initial
   run_test();
endmodule
