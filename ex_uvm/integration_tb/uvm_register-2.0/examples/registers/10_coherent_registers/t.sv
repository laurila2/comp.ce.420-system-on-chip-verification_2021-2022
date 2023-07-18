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
 * Read and write the id_register.
 */
module top;
  my_register_map rm;
  uvm_register_base registers[];
  my_coherent_master m;
  bit [31:0] d;

  initial begin
    rm = new("rm", null);

    // Get the list of registers in the address map.
    rm.get_register_array(registers);

    // Print the address map
    rm.display_address_map();

    $display("---------------------------");
    $display(
      " Test1: Coherent Register - reading from the master");

	// Fill the registers up with some data.
	$display("...Writing the INITIAL values...");
	// This is "A".
    foreach (registers[i])
	  registers[i].write_data32(i);

	for (int loop_counter = 0; loop_counter < 10; loop_counter++) begin

	  // Cause a "snapshot()" of each slave - by reading the master.
      foreach (registers[i])
        if ($cast(m, registers[i])) begin
          $display("...Doing read() on %s",
            registers[i].get_full_name());
		  d = m.read();
	    end
  
	  // Write other data to the slaves (and the master)
	  // This might be a slave updating it's internal counter...
	  $display("...Writing the NEXT values... (%0d's)", loop_counter*100);

	  // This is "B".
      foreach (registers[i])
	    registers[i].write_data32(loop_counter*100+i);
  

	  // Read the slave. We should get the FIRST values from "A" above.
	  // Or the previous loop_counter.
	  // We should NOT get the values from B.
	  if (loop_counter != 0)
        foreach (registers[i]) begin
          $display("Register %s = %s (%0x)",
            registers[i].get_full_name(),
            registers[i].convert2string(),
            registers[i].peek_data32());
		    if ( !$cast(m, registers[i]) )
              if (registers[i].peek_data32() != (loop_counter-1)*100+i)
		        $display("ERROR: Mismatch. Expected '%0d', found '%0d'",
		         (loop_counter-1)*100+i, registers[i].peek_data32());
	    end
    end
  end
endmodule
