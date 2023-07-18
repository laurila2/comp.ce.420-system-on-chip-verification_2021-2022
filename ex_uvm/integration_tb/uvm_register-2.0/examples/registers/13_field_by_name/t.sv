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
import my_registers_pkg::*;

my_register_file rm;

module top;
  regB gazillion[3/*100000*/];

  regA a;
  uvm_register_base a_base;

  task monitor_a();
    wait(a!=null);
    forever
      @(a.data)
      $display("%2s: A = %s (%x (%0d))", 
        "ma", a.convert2string(), 
        a.data, 
        a.data);
  endtask

  task automatic monitor_b();
    foreach (gazillion[i])
      fork
        int j = i;
        forever @(gazillion[j].data) begin
          $display("%2s: B = %s (%x (%0d))", 
            "mb", gazillion[j].convert2string(),
            gazillion[j].data,
            gazillion[j].data);
        end
      join_none
  endtask

  task reset_a_field_by_name();
    $display(" -- %m");
    $display("%2s: A = %s (current)", 
      "ra", a_base.convert2string());
    a_base.reset_field_by_name("f1");
    a_base.reset_field_by_name("f2");
    a_base.reset_field_by_name("f3");
    #1; // Let the monitor catch up.
    $display("%2s: A = %s (after reset)", 
      "ra", a_base.convert2string());
  endtask

  task reset_b_field_by_name();
    uvm_register_base b_base;
    $display(" -- %m");
    foreach (gazillion[i]) begin
      b_base = gazillion[i];
      $display("%2s: B = %s (current)", 
        "rb", b_base.convert2string());
      b_base.reset_field_by_name("f1");
      b_base.reset_field_by_name("f2");
      b_base.reset_field_by_name("f0");
      #1; // Let the monitor catch up.
      $display("%2s: B = %s (after reset)", 
        "rb", b_base.convert2string());
    end
  endtask

  task test_reset();
    $display("---------- %m");
    a.poke('0);
    #1;
    $display("%2s: A = %s (poked 0)", 
      "r", a.convert2string());
    a_base.reset_field_by_name("f1");
    a_base.reset_field_by_name("f2");
    a_base.reset_field_by_name("f3");
    #1;
    $display("%2s: A = %s (reset_field_by_name)", 
      "r", a.convert2string());

    #10;
    a.poke('1);
    #1;
    $display("%2s: A = %s (poked 1)", 
      "r", a.convert2string());
    a_base.reset_field_by_name("f1");
    a_base.reset_field_by_name("f2");
    a_base.reset_field_by_name("f3");
    #1;
    $display("%2s: A = %s (reset_field_by_name)", 
      "r", a.convert2string());
  endtask

  task test0_poke();
    $display("---------- %m");
    reset_a_field_by_name();
    for(int i = 0; i < 64; i++) begin
      a.poke(i);
      $display("%2s: A = %s (poked %x (%0d)", 
        "0p", a.convert2string(), i, i);
      #100;
    end
  endtask

  task test0_write();
    $display("---------- %m");
    reset_a_field_by_name();
    for(int i = 0; i < 64; i++) begin
      a.write(i);
      $display("%2s: A = %s (wrote %x (%0d))", 
        "0w", a.convert2string(), i , i);
      #100;
    end
  endtask

  task test1_poke_field_by_name();
    regA_fields_t v, regA_fields;
    $display("---------- %m");
    reset_a_field_by_name();
    for(int i_f1 = 0; i_f1 < 2; i_f1++) begin
      for(int i_f2 = 0; i_f2 < 4; i_f2++) begin
        for(int i_f3 = 0; i_f3 < 8; i_f3++) begin
          a_base.poke_field_by_name("f1", i_f1);
          a_base.poke_field_by_name("f2", i_f2);
          a_base.poke_field_by_name("f3", i_f3);
          v = a.read();
          regA_fields = '{i_f1, i_f2, i_f3};
          $display("%2s: A = %s (poked {%0p} %0x (%0d))", 
            "p", a.convert2string(), 
            regA_fields, regA_fields, regA_fields);
          $display("%2s: A = %s (read  {%0p} %0x (%0d))", 
            "r", a.convert2string(), 
            v, v, v);
          #100;
        end
      end
    end
  endtask

  task test2_write_field_by_name();
    regA_fields_t v, regA_fields;
    $display("---------- %m");
    reset_a_field_by_name();
    for(int i_f1 = 0; i_f1 < 2; i_f1++) begin
      for(int i_f2 = 0; i_f2 < 4; i_f2++) begin
        for(int i_f3 = 0; i_f3 < 8; i_f3++) begin
          a_base.write_field_by_name("f1", i_f1);
          a_base.write_field_by_name("f2", i_f2);
          a_base.write_field_by_name("f3", i_f3);
          regA_fields = '{i_f1, i_f2, i_f3};
          v = a.peek();
          $display("%2s: A = %s (wrote {%0p} %0x (%0d))", 
            "w", a.convert2string(), 
            regA_fields, regA_fields, regA_fields);
          $display("%2s: A = %s (peekd {%0p} %0x (%0d))", 
            "p", a.convert2string(), 
            v, v, v);
          #100;
        end
      end
    end
  endtask

  task drive_a();
    $display("---------- %m");
    test_reset();
    test0_poke();
    test0_write();
    test1_poke_field_by_name();
    test2_write_field_by_name();
  endtask

  task drive_b();
    $display("---------- %m");
    $display("  -------- %m poke(0)");
    rm_poke(0);
    #10;
    rm.display_address_map();

    $display("  -------- %m poke(1)");
    rm_poke('1);
    #10;
    rm.display_address_map();

    $display("  -------- %m write(0)");
    rm_write(0);
    #10;
    rm.display_address_map();

    $display("  -------- %m write(1)");
    rm_write('1);
    #10;
    rm.display_address_map();

    $display("  -------- %m rm.reset()");
    rm.reset();
    #10;
    rm.display_address_map();

    $display("  -------- %m poke(1)");
    rm_poke('1);
    #10;
    rm.display_address_map();

    reset_a_field_by_name();
    reset_b_field_by_name();
    #10;
    rm.display_address_map();
  endtask

  task rm_write(bit [31:0] v);
    register_list_t register;
    rm.get_register_array(register);
    foreach (register[i])
      register[i].write_data32(v);
  endtask

  task rm_poke(bit [31:0] v);
    register_list_t register;
    rm.get_register_array(register);
    foreach (register[i])
      register[i].poke_data32(v);
  endtask

  initial begin

    // Allocate the register map (really a register file,
    //  but it doesn't matter).
    rm = new("rm", null);

    // Allocate registers.
    a = new("a", rm);
    a_base = a;
    rm.add_register(a.get_full_name(), 'h10, a);

    foreach (gazillion[i]) begin
      gazillion[i] = new($psprintf("GZ%0d", i), rm);
      rm.add_register(gazillion[i].get_full_name(), 
        'h1000+i, gazillion[i]);
    end
    rm.display_address_map();
    rm.print_fields();

    // Start some monitors, so we can see when things
    // change.
    fork
      monitor_a();
      monitor_b();
    join_none

	#1;
    $display("");
    $display("Starting tests....");
    $display("");

    reset_a_field_by_name();
    rm.display_address_map();

    drive_a();
    drive_b();

    $display("  -------- %m reset_field_by_name_with_tag(TAG1)");
    rm_poke(0);
	#10;
    rm.reset_field_by_name_with_tag("TAG1");
    #10;
    rm.display_address_map();

    $display("  -------- %m reset_field_by_name_with_tag(TAG3)");
    rm_poke(0);
    rm.reset_field_by_name_with_tag("TAG3");
    #10;
    rm.display_address_map();

    $finish(2);
  end
endmodule
