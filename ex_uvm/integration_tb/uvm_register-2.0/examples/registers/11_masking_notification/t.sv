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
 * Read and write the id_register.
 */
module top;
  my_register_map rm;
  my_register_map rm_stimulus;
  uvm_register_base registers[];
  bit [31:0] d;

  initial begin
    uvm_object o;
    my_regular_register r, ro;

    fields_t r_raw_value,     r_raw_value2;
    fields_t ro_raw_value,    ro_raw_value2;
    fields_t r_behave_value,  r_behave_value2;
    fields_t ro_behave_value, ro_behave_value2;

    int check_shadow_stuff = 0;

    fields_t new_value, existing_value;

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
    $display(" Test: Run mask test");

    /*
     * Test the "special" permission register.
     * In this case we know this is a READONLY register,
     * so the test consists of:
     *
     * Test 1
     *  1. Write to the actual register
     *
     *  2. peek the actual and the special registers
     *     compare the values.
     *
     *  3. read the actial and the special registers
     *     compare the values.
     *
     * Test 2
     *  1. Write to the special register
     *  2. Check to see that the actual register is unchanged.
     *
     */
    begin
      if (uvm_top.get_config_object("A", o, 0 ))
        $cast(r, o);
      if (uvm_top.get_config_object("A_ro", o, 0))
        $cast(ro, o);

      // Don't use poke()! We want to set the data that is NEVER used.
      ro.data = '1; // Should never change.

      $display("\nRegister %s shadows %s", 
        ro.get_full_name(), r.get_full_name());
    end

    foreach (registers[i]) begin
      $display("\nRegister %s",
        registers[i].get_full_name());

      $cast(r, registers[i]);

      check_shadow_stuff = 0;
      if (ro.get_actual_register() == r) 
        check_shadow_stuff = 1;

      for(int existing_v = 0; existing_v < 2 ; existing_v++) begin
        if (existing_v == 0) existing_value = '0;
        else                 existing_value = '1;

        for(int v = 0; v < 2 ; v++) begin
          // 'new_value' is the value we are writing or poking.
          if (v == 0) new_value = '0;
          else        new_value = '1;

          // ----------------------------------------
          // Begin RAW test. Access RAW, no behavior.
          // ----------------------------------------
          // Reset the register value.
          r.poke(existing_value);

          r.poke(new_value);      // Poke it.
          r_raw_value = r.peek(); // Peek it.
                                  // Print it.

          // -----------------------------------------
          // Begin BEHAVE test. Access using behavior.
          // -----------------------------------------
          // Reset the register value.
          r.poke(existing_value);

          r.write(new_value);          // Write it.
          r_raw_value2    = r.peek();  // Peek it. Just to see what write()
                                       //          did without read() interfering.
          r_behave_value  = r.read();  // Read it.
          r_behave_value2 = r.read();  // Read it. Again.

          if (check_shadow_stuff) begin
            r.poke(existing_value);
            r.write(new_value);        // Write it.
            ro_raw_value2 = ro.peek();
            ro_behave_value = ro.read();
            ro_behave_value2 = ro.read();
          end
                                       // Print it.

          $display("");
          $display("***Value to write %p,",    new_value);
          $display("..Current Value =(%p)",  existing_value);
          $display("             poke(%p),",   new_value);
          $display("       Get peek()=%p,",    r_raw_value);
          $display("");
          $display("..Current Value =(%p)",  existing_value);
          $display("            write(%p),",   new_value);
          $display("       Get peek()=%p, (after the write)",    
                                               r_raw_value2);
          $display("       Get read()=%p,",    r_behave_value);
          $display("       Get read()=%p, #2", r_behave_value2);

          if (check_shadow_stuff) begin
              fields_t v;
              v = '1;
              // Don't use peek()! We want the data that is NEVER used.
              if (ro.data != v) 
                $display("Error: WRONG DATA");

          $display("..Current Value =(%p)",  existing_value);
          $display("            write(%p),",   new_value);
          $display("    Get ro.peek()=%p, (after the write)",    
                                               ro_raw_value2);
          $display("    Get ro.read()=%p,",    ro_behave_value);
          $display("    Get ro.read()=%p, #2", ro_behave_value2);

            if (ro.peek() != r.peek())
              $display("Error: MISMATCH");
          end
        end
      end
    end

    //RICH $cast(rm_stimulus, rm.clone());
    //RICH assert(rm_stimulus.randomize());
    //RICH rm.display_address_map();
    //RICH rm_stimulus.display_address_map();

  end
endmodule
