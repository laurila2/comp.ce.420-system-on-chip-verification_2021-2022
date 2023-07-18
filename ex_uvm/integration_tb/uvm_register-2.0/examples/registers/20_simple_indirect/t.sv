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
 * Write and read the indirect registers.
 */
module top;
  my_register_map rm;
  uvm_register_base registers[];

  initial begin
    rm = new("rm", null);

    // Get the list of registers in the address map.
    rm.get_register_array(registers);
    // Send every register into reset.
    foreach (registers[i]) begin
      registers[i].reset();
    end

    // Print the address map
    rm.display_address_map();

    begin
    uvm_indirect_address_register #(bit[31:0]) address_register;
    uvm_indirect_register         #(bit[31:0])    data_register;
    bit[31:0] value;

    $display("---------------------------");
    $display(
      " Test: Write Address, then 4 data, read back");

    // Setup all the address registers we have.
    foreach (registers[i]) begin
      if ($cast(address_register, registers[i])) begin
        address_register.write(0);
        $display("Register %s = %s",
          address_register.get_full_name(),
          address_register.convert2string());
      end
    end

    // Write 4 times to each data register
    foreach (registers[i]) begin
      if ($cast(data_register, registers[i])) begin
        for(int j = 0; j < 4; j++) begin
          // Write 1, 2, 3, 4
          data_register.write(j+1);
          $display("Register %s = %s",
              data_register.get_full_name(),
              data_register.convert2string());
        end
      end
    end

    // Print the address map
    rm.display_address_map();

    // Setup all the address registers we have.
    foreach (registers[i]) begin
      if ($cast(address_register, registers[i])) begin
        address_register.write(0);
        $display("Register %s = %s",
          address_register.get_full_name(),
          address_register.convert2string());
      end
    end

    // Read 4 times to from data register
    foreach (registers[i]) begin
      if ($cast(data_register, registers[i])) begin
        for(int j = 0; j < 4; j++) begin
          // Read... 
          value = data_register.read();
          $display("Register %s read as %0x",
              data_register.get_full_name(),
              value);
        end
      end
    end

    // Print the address map
    rm.display_address_map();
    end
  end
endmodule
