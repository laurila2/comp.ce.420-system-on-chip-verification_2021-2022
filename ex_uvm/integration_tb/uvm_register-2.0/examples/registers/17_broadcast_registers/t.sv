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
 * Print the address map.
 * Write the broadcast register.
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
    $display(
      " Test: Broadcast Register - using the broadcast register");

    // Fill the registers up with some data.
    // Don't write to the broadcast register. Just initialize
    // everything else.
	begin
	  uvm_broadcast_register #(bit[31:0]) b;
      $display("...Writing the INITIAL values...");
      foreach (registers[i])
        if ( !$cast(b, registers[i]) ) begin
          $display("...Initializing register %s",
            registers[i].get_full_name());
          registers[i].write_data32(i);
        end
	end

    $display("---------------------------");
    $display( " Test: Initial Values");
    // Print the address map
    rm.display_address_map();

    // Lookup by Name if you want.
    // $cast(r, 
    //   rm.lookup_register_by_name("rm.broadcast.regA_broadcast"));
    // $cast(r, 
    //   rm.lookup_register_by_name("rm.broadcast.regB_broadcast"));

    // Or lookup by address. 
	//
	// Secret: We know what the broadcast addresses are - we're 
	// using them to lookup the register we want to "write" to. 
	// When we write to that register, it will actually cause 
	// writes to the other "target" registers.
    $cast(r, rm.lookup_register_by_address('h10001));
    $display("...Doing broadcast on %s",
      r.get_full_name());
    r.write_data32('h42);

    $cast(r, rm.lookup_register_by_address('h10002));
    $display("...Doing broadcast on %s",
      r.get_full_name());
    r.write_data32('h43);

    $display("---------------------------");
    $display( " Test: Final Values");
    // Print the address map
    rm.display_address_map();
  end
endmodule
