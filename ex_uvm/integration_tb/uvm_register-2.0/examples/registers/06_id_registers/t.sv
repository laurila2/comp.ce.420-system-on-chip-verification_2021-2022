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
  my_id_register id;
  bit [31:0] d;

  initial begin
    rm = new("rm", null);

    // Get the list of registers in the address map.
    // 2.0 PORT registers = rm.get_register_array();
// 2.0 PORT ** Error: t.sv(40): Function with return type of void cannot be used in/as an expression.
// 2.0 PORT ** Error: t.sv(40): No actual value has been specified for a formal argument 'register_array' that does not have a default value.
// 2.0 PORT ** Error: t.sv(40): Number of actuals and formals does not match in function call.
    rm.get_register_array(registers);
    // Send every register into reset.
    foreach (registers[i]) begin
      registers[i].reset();
    end

    // Print the address map
    rm.display_address_map();

    $display("---------------------------");
    $display(
      " Test: multiple (9) reads in a row on each register");
    // For each register, show it's name and value,
    // then try to read it N times in a row.
    // For id_registers, we should get the successive
    // data values.
    foreach (registers[i]) begin
      $display("Register %s = %s",
        registers[i].get_full_name(),
        registers[i].convert2string());

      for(int j = 1; j < 9; j++)
        $display(" ... (%s) read() #%2d = %0x", 
          registers[i].get_full_name(),
          j, registers[i].read_data32());
    end

    $display("---------------------------");
    $display(
      " Test: reseting the pointer to 0 on each register");
    //
    // Test the write() operation 
    //  ("set_data32()" operation )
    //  on an id_register.
    //
    // For ONLY the id_registers, read twice (to
    // set the read pointer past 0), then
    // do a write to set the read pointer to 0,
    // then confirm that the first value is read.
    foreach (registers[i]) begin
      // Check to make sure this is an ID register
      // Use a cast to an id_register to make sure.
      if ($cast(id, registers[i])) begin
        // Read twice, then go back to 0.
        void'(registers[i].read_data32());
        void'(registers[i].read_data32());

        // Write the pointer.
        registers[i].write_data32(0);
        // Now read - we should be getting the FIRST value.
        d = registers[i].read_data32();

        $display(" ... (%s) First item is %0x", 
          registers[i].get_full_name(), d);
      end 
      else begin
        $display(" ... (%s) Skipping. Not an id_register",
          registers[i].get_full_name());
      end
    end

    $display("---------------------------");
    $display(" Test: index reads on each register");
    foreach (registers[i]) begin
      // Check to make sure this is an ID register
      // Use a cast to an id_register to make sure.
      if ($cast(id, registers[i])) begin
        for (int j = 0; j < id.get_length(); j++) begin
          // Set the pointer to a value.
          id.write_data32(j);
          // Now read it.
          d = id.read_data32();
          $display(" ... (%s) Indexed read[%0d] = %0x",
            id.get_full_name(), j, d);
        end
      end
      else begin
        $display(" ... (%s) Skipping. Not an id_register",
          registers[i].get_full_name());
      end
    end
  end
endmodule
