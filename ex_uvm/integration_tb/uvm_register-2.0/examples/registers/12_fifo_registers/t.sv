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
 * Read and write the fifo_register.
 */
module top;
  my_register_map rm;
  uvm_register_base registers[];
  my_fifo_register fifo;
  bit [31:0] d;

  function automatic void test_fifo(my_fifo_register fifo, int n);
    bit [31:0] read_data;

	for(int i = 0; i < n; i++) begin
      $display("Writing %s = %0x", 
	    fifo.get_full_name(), i);
	  fifo.write(i);
    end

    // The fifo is now at maximum "fullness".
    // Print it out.
    $display("FIFO is '%s' (1)", fifo.convert2string());
    $display("FIFO is '%s' (2)", fifo.convert2string_alternate());

	for(int i = 0; i < n; i++) begin
	  read_data = fifo.read();
	  $display("...read %s = %0x",
	    fifo.get_full_name(), read_data);
  
	  if ( read_data != i )
	    $display("Error: mismatch. Expecting '%x', Read '%x'",
		  i, read_data);
     end
  endfunction

  initial begin
    rm = new("rm", null);

    // Get the list of registers in the address map.
    rm.get_register_array(registers);
    // Send every register into reset.
    foreach (registers[i])
      registers[i].reset();

    $display("---------------------------");
    $display(" Test: Write an initial value into each fifo");
    foreach (registers[i]) begin
      // Check to make sure this is a FIFO register
      if ($cast(fifo, registers[i])) begin
		$cast(fifo, registers[i]);
		fifo.write(0);
	  end
    end

    // Print the address map
    rm.display_address_map();

    $display("---------------------------");
    $display(" Test: Read the FIFO");
    // For each register, show it's name and value,
    // then try to read it.
    foreach (registers[i]) begin
      $display("Register %s = %s",
        registers[i].get_full_name(),
        registers[i].convert2string());

      $display(" ... (%s) read() = %0x", 
        registers[i].get_full_name(),
        registers[i].read_data32());
    end

    $display("---------------------------");
    $display(" Test: Write/Read on each fifo");
    foreach (registers[i]) begin
      // Check to make sure this is a FIFO register
      if ($cast(fifo, registers[i]))
		test_fifo(fifo, 10);
      else 
        $display(" ... (%s) Skipping. Not a fifo register",
          registers[i].get_full_name());
    end
  end
endmodule
