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
import stopwatch_register_pkg::*;

`include "uvm_macros.svh"

typedef enum {READ_op, W_op} op_t;
class my_bus_transaction extends uvm_sequence_item;
  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand op_t       rw;

  `uvm_object_utils_begin(my_bus_transaction)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_enum(op_t, rw, UVM_ALL_ON)
  `uvm_object_utils_end

   function string convert2string();
     string s;
     // $sformat(s, "%p", this);
     $sformat(s, "BUS_OPERATION(%s, %0x, %0x)", 
       rw, addr, data);
     return s;
   endfunction
endclass

class bus_driver #(type REQ = int) extends uvm_driver#(REQ);
  my_bus_transaction item;

  bit [31:0] memory[int];

  function new(string name, uvm_component p);
    super.new(name, p);
  endfunction

  task run();
    uvm_report_info("DRVR", "Starting");
    forever begin
      seq_item_port.get(item);

      // Simple memory access
      if (item.rw == READ_op) begin
        if (memory.exists(item.addr))
          item.data = memory[item.addr];
        else
          item.data = 'hdeadbeef;
        uvm_report_info("DRVR", {"Wiggling pins - ", 
          item.convert2string()});
        #70;
      end
      else if (item.rw == W_op) begin
        memory[item.addr] = item.data;
        uvm_report_info("DRVR", {"Wiggling pins - ", 
          item.convert2string()});
        #50;
      end
      else begin
        item.data = 'h12345678;
        uvm_report_error("REG", 
          $psprintf("Unknown operation '%s'", item.rw));
      end
      rsp_port.write(item);
    end
  endtask
endclass

class bus_sequence #(type T = int) extends uvm_sequence#(T);
  my_bus_transaction item;

  task send_to_bus(my_bus_transaction req, 
      output my_bus_transaction rsp);
    wait_for_grant();
    send_request(req);
    get_response(rsp);
  endtask

  task body();
    for (int i = 0; i < 10; i++) begin
      item = new();
      assert(item.randomize());
      send_to_bus(item, item);
    end
  endtask
endclass

class my_sequencer #(type REQ = int, type RSP = REQ) 
    extends uvm_sequencer #(REQ, RSP);

  // Ports like a DRIVER.
  uvm_seq_item_pull_port 
    #(uvm_register_transaction, 
      uvm_register_transaction) register_seq_item_port;
  uvm_analysis_port 
    #(uvm_register_transaction) register_rsp_port;

  // The register sequencer that will run the register
  // sequence.
  uvm_register_sequencer 
    #(uvm_register_transaction) m_register_sequencer;

  function new(string name, uvm_component p);
    super.new(name, p);
  endfunction

  function void build();
    super.build();
    register_seq_item_port = 
      new("register_seq_item_port", this);
    register_rsp_port = 
      new("register_rsp_port",      this);
    m_register_sequencer = 
      new("m_register_sequencer",   this);
  endfunction

  function void connect();
    super.connect();
    register_seq_item_port.connect(
      m_register_sequencer.seq_item_export);
    register_rsp_port.connect(     
      m_register_sequencer.rsp_export); 
  endfunction
endclass

class translate_sequence #(type T = int) 
    extends bus_sequence#(T);

   task body();
     // Register request and response from the automated
     // register testing side.
     uvm_register_transaction register_req, register_rsp;

     // Register map to map name to address.
     uvm_register_map register_map;
     bit valid_address;

     // The sequencer we are running on.
     uvm_sequencer_base sqr = get_sequencer();
     // The actual type we are running on (with the 
     //  port and analysis port we need).
     my_sequencer #(T) p_sqr;

     assert($cast(p_sqr, sqr));

     register_map =
       uvm_register_map::uvm_register_get_register_map();

     req = new();
     forever begin
       // Get a register request.
       p_sqr.register_seq_item_port.get(register_req);

       // Create the response from the request. To be
       // further refined below as the response comes back
       // from the bus transaction.
       register_rsp = new();
       register_rsp.copy_req(register_req);
       register_rsp.set_id_info(register_req);

       // Map the operation.
       req.rw = W_op;
       if (register_req.op == uvm_register_pkg::READ)
         req.rw = READ_op;

       // Change the register name into an address.
       req.addr = 
         register_map.lookup_register_address_by_name(
           register_req.name, valid_address);

       // Check to see if this register is mapped.
       if (!valid_address) begin
         // Register is NOT mapped to an address.
         uvm_report_error("REG", 
           $psprintf(
"Illegal register address - register '%s' not found",
           register_req.name));
         register_rsp.status = uvm_register_pkg::FAIL;
       end
       else begin
         // Register is mapped to an address.

         // Pass the data - really only needed for a write.
         req.data = register_req.data;
  
         send_to_bus(req, rsp);

         // Copy the returned data back - really only 
         // needed for a read.
         register_rsp.data = rsp.data;
         register_rsp.status = uvm_register_pkg::PASS;
       end
  
       // Send back a register response.
       p_sqr.register_rsp_port.write(register_rsp);
     end
   endtask
endclass

class env extends uvm_env;
  bus_driver   #(my_bus_transaction) d;
  my_sequencer #(my_bus_transaction) sqr;

  function new(string name, uvm_component p);
    super.new(name, p);
  endfunction

  function void build();
    d   = new("d", this);
    sqr = new("sqr", this);

    set_config_int("*", "count", 0);
  endfunction

  function void connect();
    d.seq_item_port.connect(sqr.seq_item_export);
    d.rsp_port.connect(sqr.rsp_export);
  endfunction

  task run();
    bus_sequence       #(my_bus_transaction) b_seq = new();
    translate_sequence #(my_bus_transaction) t_seq = new();

    register_sequence_all_registers
        #(uvm_register_transaction, 
          uvm_register_transaction) register_sequence = new();

    uvm_report_info("ENV", "Starting");

    // ----------------------------------
    // Test 1 - Run a bunch of addresses.
    // ----------------------------------
    b_seq.start(sqr);

    // ----------------------------------
    // Test 2 - Run a built-in register sequence.
    // ----------------------------------

    // Start the translator sequence. This is a "slave"
    // sequence - start it in the background.
    fork 
      t_seq.start(sqr);
    join_none

    // Start the register sequence running on the register
    // seqeuncer.
    register_sequence.start(sqr.m_register_sequencer);

    // ----------------------------------
    // End of tests.
    // ----------------------------------
    global_stop_request();
  endtask
endclass

module top;
  env env = new("env", null);

  initial
    run_test();
endmodule
