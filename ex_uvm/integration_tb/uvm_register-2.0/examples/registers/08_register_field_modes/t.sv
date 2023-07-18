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
 * Read and write the mode register.
 */
module top;
  my_register_map rm;
  uvm_register_base registers[];
  registerA rega;

  mode1_fields_t v1;
  mode2_fields_t v2;

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

    $display("---------------------------");
    $display(
      " Test: Read");
    foreach (registers[i]) begin
      $display("Register %s = %s",
        registers[i].get_full_name(),
        registers[i].convert2string());
      assert($cast(rega, registers[i]));
      rega.write('b1111);
      $display(" ... (%s) read() = %0x", 
        registers[i].get_full_name(),
        rega.read());

      rega.set_mode("mode1");
      rega.write('b1111);
      v1 = rega.read();
      $display("(%s) Mode1: %p", rega.get_full_name(), v1);

      rega.set_mode("mode2");
      rega.write('b1111);
      v2 = rega.read();
      $display("(%s) Mode2: %p", rega.get_full_name(), v2);

      rega.set_mode("mode1");
      rega.write('b1111);
      v1 = rega.read_data32();
      $display("(%s) Mode1: %p", rega.get_full_name(), v1);

      rega.set_mode("mode2");
      rega.write('b1111);
      v2 = rega.read_data32();
      $display("(%s) Mode2: %p", rega.get_full_name(), v2);
    end

    foreach (registers[i]) begin
      uvm_register_modes_t modes;
      assert($cast(rega, registers[i]));
      // 2.0 PORT modes = rega.get_modes();
// 2.0 PORT # ** Error: (vsim-8220) t.sv(88): This or another usage of 'rega.get_modes.$$' inconsistent with '(null)' object.
// 2.0 PORT # ** Error: (vsim-3978) t.sv(88): Cannot assign a packed type to an unpacked type.
// 2.0 PORT # ** Error: (vsim-8268) t.sv(88): No Default value for formal 'modes' in task/function get_modes.
// 2.0 PORT # ** Error: (vsim-3769) t.sv(88): Function 'get_modes', which returns a void result, is used in or as an expression.

      rega.get_modes(modes);
      foreach (modes[s]) begin
        rega.set_mode(rega.modes[s]);
  
        $display("---------------------------");
        $display(
          " Test: Randomization (%s)", rega.get_mode());
        for (int j = 0; j < 8; j++) begin
          assert(rega.randomize());
          $display("(%s) %s: %s", 
            rega.get_full_name(), 
            rega.get_mode(), 
            rega.convert2string());
        end
      end
    end
  end
endmodule
