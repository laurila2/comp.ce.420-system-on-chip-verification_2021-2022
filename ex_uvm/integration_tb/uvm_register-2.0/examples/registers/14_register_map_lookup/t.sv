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
import my_registers_pkg::*;

module top;

  function void test_parse_names();
	name_list_t l;

`ifdef NOTDEF
    string names[9];
	names[0] = ".";
    names[1] = "..";
    names[2] = "a.";
    names[3] = ".a";
    names[4] = ".a.b";
    names[5] = ".a.b.";
    names[6] = "a..b.c";
    names[7] = "x.y.z";
    names[8] = "abc.bcde.cdefghi";

    for (int s = 0; s < 9; s++) begin
`else
    string names[] = '{
	  ".",
      "..",
      "a.",
      ".a",
      ".a.b",
      ".a.b.",
      "a..b.c",
      "x.y.z",
      "abc.bcde.cdefghi"
	};
	foreach (names[s]) begin
`endif
      uvm_parse_path_name(l, names[s]);
      $display("%s", 
        uvm_print_name_list(
          names[s], l)); 
	end
  endfunction

  initial begin
    USB usb;
    dut dut1;
    internal internal;
    AXI axi;
    AHB ahb;
    external external;
    rf_ns north, south;

    mapped_register_container_list 
      list_of_mapped_items;
    uvm_register_base r;
    uvm_register_file rf;

    system_map rm;

    test_parse_names();

    // Build the register map.
    rm = new("rm", null);
    rm.print_rm();

    // -----------------
    rm.find_register_container(list_of_mapped_items, "external.usb.dut1");
    $cast(dut1, list_of_mapped_items[$].container);
    dut1.print_rm();

    // -----------------
    dut1.find_register_container(list_of_mapped_items, "north.west");
    $cast(rf, list_of_mapped_items[$].container);
    rf.print_rm();

    // -----------------
    rm.find_register_container(list_of_mapped_items, "internal.ahb");
    $cast(ahb, list_of_mapped_items[$].container);
    ahb.print_rm();

    // -----------------
    // Grab a register file
    dut1.find_register_container(list_of_mapped_items, "north.west");
    $cast(rf, list_of_mapped_items[$].container);
    rf.print_rm();

    // Find a register in the register file
    r = rf.lookup_register_by_name("regA");
    r.print();

    // -----------------
    // Grab a higher register file
    dut1.find_register_container(list_of_mapped_items, "north");
    $cast(rf, list_of_mapped_items[$].container);
    rf.print_rm();

    // Find a register in the register file - fancy name
    r = rf.lookup_register_by_name("west.regA");
    r.print();
  end
endmodule
