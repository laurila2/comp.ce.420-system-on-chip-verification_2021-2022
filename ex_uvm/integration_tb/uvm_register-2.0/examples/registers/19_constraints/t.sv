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

import uvm_register_pkg::*;
import my_register_pkg::*;

/*
 * Simple test.
 *
 * Instantiate the registers, register map and register file.
 * Print the register map.
 * Loop, randomizing 10 times, print the register map.
 */
module top;
  my_register_map rm;
  uvm_register_base registers[];
  uvm_register_base r;

  initial begin
    rm = new("rm", null);

    // Get the list of registers in the address map.
    rm.get_register_array(registers);

    $display("---------------------------");
    $display(" Test: Randomize");

    // Fill the registers up with some data.
    $display("...Writing the INITIAL values...");
    foreach (registers[i]) begin
      $display("...Initializing register %s",
          registers[i].get_full_name());
      registers[i].write_data32(i);
    end

    $display("---------------------------");
    $display( " Test: Initial Values");
    // Print the address map
    rm.display_address_map();

    for (int i = 0; i < 10; i++) begin
      assert(rm.randomize());
      $display("---------------------------");
      $display( " Test: Random Values (%0d)", i);
	  rm.print_tree();
      // Print the address map
      rm.display_address_map();
    end
  end
endmodule
