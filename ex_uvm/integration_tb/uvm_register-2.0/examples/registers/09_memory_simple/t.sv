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
 */
module top;
  my_register_map rm;

  uvm_register_base registers[];
  bit [31:0] addresslist[] = '{ 
    'h1001, 
    'h2001, 
    'h80000,
    'h80001,
    'h92000,
    'h92001,
    'h12000,
    'h12001,
    'h12002,
    'h12003,
    'h12000 
    };

  uvm_register_base r;
  my_memory_little m_little;
  my_memory_big    m_big;

  bytearray_t ba, read_ba;
  //int i;

  function void do_check(my_register_map rm, bytearray_t ba);
    uvm_register_base r;
    my_memory_little m_little;
    int address;

    r = rm.lookup_register_by_name("rm.device2.mem_little");
    if ($cast(m_little, r)) begin
      address = m_little.start_address;

      $display("...addr=0x%0x (writing %p)", address, ba);

      rm.poke_bytes(address, ba);

      m_little.bus_read(ba, address);

      rm.bus_read(ba, address);

      rm.peek_bytes(read_ba, address, ba.size());

      foreach (ba[j])
        if (ba[j] != read_ba[j])
          // Mismatch!
          $display(
"Mismatch - Addr=%x (%d) wrote byte %d as 0x%x, read 0x%x", 
              address, address, 
              j, ba[j], read_ba[j]);
    end
    else begin
      $display("Error: Cannot find %s", "rm.device2.mem_little");
    end
    rm.display_address_map();
  endfunction

  initial begin
    rm = new("rm", null);
    ba = new[4];

    // Get the list of registers in the address map.
    rm.get_register_array(registers);

    // Print the address map
    rm.display_address_map();

    $display("---------------------------");
    $display(
      " Test1. For my favorite addresses, update memory");

    // Write data - knowing what kind of model is at the
    // address (memory or register).
    foreach (addresslist[i]) begin
      r = rm.lookup_register_by_address(addresslist[i]);
      if (r != null) begin
        $display("Address %0x is %s", 
          addresslist[i], r.get_full_name());
        if (r.isMemory()) begin
          if ($cast(m_little, r)) begin
            ba[3] = i;
            m_little.poke_bytes(addresslist[i], ba);
          end
          else if ($cast(m_big, r)) begin
            ba[3] = i;
            m_big.poke_bytes(addresslist[i], ba);
          end
          else
            $display("ERROR: $cast() failed for memory");
        end
        else
          r.write_data32(42);
      end
      else
        $display("Address %0x is not mapped", addresslist[i]);
    end

    // Read some addresses in the register map.
    foreach (addresslist[i]) begin
      rm.peek_bytes(read_ba, addresslist[i], ba.size());
      $write("MEM[%0x] = '{", addresslist[i]);
      foreach (read_ba[i]) 
        $write(" %0x", read_ba[i]);
      $display("}");
    end
    rm.display_address_map();

    //
    // For each address, write a value, then
    // read it back and check it.
    //
    ba = '{1, 2, 3, 4};
    foreach (addresslist[i]) begin
      $display("...addr=0x%0x (writing %p)", 
        addresslist[i], ba);

      rm.poke_bytes(addresslist[i], ba);
      rm.peek_bytes(read_ba, addresslist[i], ba.size());

      foreach (ba[j])
        if (ba[j] != read_ba[j])
          // Mismatch!
          $display(
"Mismatch - Addr=%x (%d) wrote byte %d as 0x%x, read 0x%x", 
              addresslist[i], addresslist[i], 
              j, ba[j], read_ba[j]);
    end
    rm.display_address_map();

    ba = '{'h4, 'h5, 'h6, 'h7, 'h8, 'h9, 'ha, 'hb, 'hc, 'hd, 'he, 'hf};
    do_check(rm, ba);

    ba = '{'hf};
    do_check(rm, ba);

    ba = '{'h5, 'h4, 'h3, 'h2, 'h1};
    do_check(rm, ba);
  end

  initial begin
	my_register_map my_rm;
    my_rm = new("my_rm", null);

    ba = '{'h5, 'h4, 'h3, 'h2, 'h1};
	my_rm.poke_bytes('h92000, ba);
	my_rm.display_address_map();

    ba = '{'h1};
    my_rm.bus_read(ba, 'h92001);
	my_rm.display_address_map();
  end
endmodule
