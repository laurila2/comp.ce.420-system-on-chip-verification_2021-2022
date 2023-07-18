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
     $sformat(s, "T(%s, %0x, %0x)", rw, addr, data);
     return s;
   endfunction
endclass

class bus_driver #(type REQ = int) extends uvm_driver#(REQ);
  my_bus_transaction item;

  function new(string name, uvm_component p);
    super.new(name, p);
  endfunction

  task run();
    uvm_report_info("DRVR", "Starting");
    forever begin
      seq_item_port.get(item);
      uvm_report_info("DRVR", {"Wiggling pins - ", 
        item.convert2string()});
      #100;
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

class register_sequence #(type T = int) 
    extends bus_sequence#(T); 

  task body();
    uvm_register_base r, registers[];
    uvm_register_map rm;
    bit valid_address;

    // 'T' is going to be a my_bus_transaction 
    //   or some derivative.
    T bus_req, bus_rsp;

    bus_req = new();
    bus_rsp = new();
    rm = uvm_register_map::uvm_register_get_register_map();

    // Get the list from 'rm'.
    rm.get_register_array(registers);
//2.0 PORT registers = rm.get_register_array();
//         rm.get_register_array(registers);
//2.0 PORT ** Error: t.sv(101): Field/method name ($$) not in 'get_register_array'
//2.0 PORT ** Error: t.sv(101): Function with return type of void cannot be used in/as an expression.
//2.0 PORT ** Error: t.sv(101): No actual value has been specified for a formal argument 'register_array' that does not have a default value.
//2.0 PORT ** Error: t.sv(101): Number of actuals and formals does not match in function call.
    foreach (registers[i]) begin
      // Go through the list and create a bus transaction.
      r = registers[i];

      // Make sure the value is the reset value.
      r.reset();

      uvm_report_info("RSQR", 
        $psprintf("Register %s, resetVal = %0h", 
          r.get_fullname(), r.get_data32()));

      // Build a bus request to send.
      bus_req.addr = rm.lookup_register_address_by_name(
                  r.get_fullname(), valid_address);
      bus_req.data = r.get_data32();
      bus_req.rw   = READ_op;

      // Send it. Get the response.
      send_to_bus(bus_req, bus_rsp);
    end
  endtask
endclass

class reset_all_sequence #(type T = int) 
    extends bus_sequence#(T); 
  task body();
    uvm_register_base r, registers[];
    uvm_register_map rm;
    bit valid_address;

    // 'T' is going to be a my_bus_transaction 
    //   or some derivative.
    T bus_req, bus_rsp;

    bus_req = new();
    bus_rsp = new();
    rm = uvm_register_map::uvm_register_get_register_map();

    // Get the list from 'rm'.
    rm.get_register_array(registers);
    foreach (registers[i]) begin
      // Go through the list and create a bus transaction.
      r = registers[i];

      // Make sure the shadow value is the reset value.
      r.reset();

      uvm_report_info("RSQR", 
        $psprintf("Register %s, resetVal = %0h", 
          r.get_fullname(), r.get_data32()));

      // Build a bus request to send.
      bus_req.addr = rm.lookup_register_address_by_name(
                  r.get_fullname(), valid_address);
      bus_req.data = r.get_data32();
      bus_req.rw   = W_op;

      // Send it. Get the response.
      send_to_bus(bus_req, bus_rsp);

      bus_req.rw   = READ_op;

      // Send it. Get the response.
      send_to_bus(bus_req, bus_rsp);

      r.bus_read32(bus_rsp.data);
    end
  endtask
endclass

class random_data_sequence #(type T = int) 
    extends bus_sequence#(T); 
  rand stopwatch_register_map my_rm;

  constraint c1 {
       my_rm.sw1.stopwatch_csr_reg.data.padding == 'h21;
  }
  task body();
    uvm_register_base r, registers[];
    uvm_register_map rm;
    bit valid_address;
    stopwatch_csr csr;


    // 'T' is going to be a my_bus_transaction 
    //   or some derivative.
    T bus_req, bus_rsp;

    bus_req = new();
    bus_rsp = new();
    rm = uvm_register_map::
      uvm_register_get_register_map();

    assert($cast(my_rm, rm));
    assert(my_rm.sw1.stopwatch_csr_reg.randomize() with 
      {my_rm.sw1.stopwatch_csr_reg.data.stride == 3;
       my_rm.sw1.stopwatch_csr_reg.data.padding == 21;
      });

    uvm_report_info("RSQR", 
        $psprintf("Register %s, value = %s", 
          my_rm.sw1.stopwatch_csr_reg.get_fullname(), 
          my_rm.sw1.stopwatch_csr_reg.convert2string()));

    // Get the list from 'rm'.
    rm.get_register_array(registers);
    foreach (registers[i]) begin
      r = registers[i];

      assert(r.randomize());

      if ($cast(csr, r)) begin
        uvm_report_info("RSQR", 
          $psprintf("%s a CSR", r.get_full_name()));
        assert(r.randomize() with {csr.data.stride == 3;});
      end
      else begin
        uvm_report_info("RSQR", 
          $psprintf("%s not a CSR", r.get_full_name()));
      end


      uvm_report_info("RSQR", 
        $psprintf("Register %s, value = %s", 
          r.get_fullname(), r.convert2string()));

      uvm_report_info("RSQR", 
        $psprintf("Register %s, value = %0h", 
          r.get_fullname(), r.get_data32()));

      // Build a bus request to send.
      bus_req.addr = 
              rm.lookup_register_address_by_name(
               r.get_fullname(), valid_address);
      bus_req.data = r.get_data32();
      bus_req.rw   = W_op;

      // Send it. Get the response.
      send_to_bus(bus_req, bus_rsp);
    end
  endtask
endclass

class configure_sequence #(type T = int) 
    extends bus_sequence#(T); 
  task body();
    uvm_register_base r, registers[];
    uvm_register_map rm;
    bit valid_address;

    // 'T' is going to be a my_bus_transaction 
    //   or some derivative.
    T bus_req, bus_rsp;

    bus_req = new();
    bus_rsp = new();
    rm = uvm_register_map::
      uvm_register_get_register_map();

    // Get the list from 'rm'.
    rm.get_register_array(registers);
    foreach (registers[i]) begin
      r = registers[i];

      uvm_report_info("RSQR", 
        $psprintf("Register %s, value = %0h", 
          r.get_fullname(), r.get_data32()));

      // Build a bus request to send.
      bus_req.addr = 
              rm.lookup_register_address_by_name(
               r.get_fullname(), valid_address);
      bus_req.data = r.get_data32();
      bus_req.rw   = W_op;

      // Send it. Get the response.
      send_to_bus(bus_req, bus_rsp);
    end
  endtask
endclass

class env extends uvm_env;
  bus_driver    #(my_bus_transaction) d;
  uvm_sequencer #(my_bus_transaction) sqr;

  function new(string name, uvm_component p);
    super.new(name, p);
  endfunction

  function void build();
    d   = new("d", this);
    sqr = new("sqr", this);
  endfunction

  function void connect();
    d.seq_item_port.connect(sqr.seq_item_export);
    d.rsp_port.connect(sqr.rsp_export);
  endfunction

  task run();
    bus_sequence         #(my_bus_transaction) b_seq;

    register_sequence    #(my_bus_transaction) register_seq;
    reset_all_sequence   #(my_bus_transaction) reset_seq; 
    configure_sequence   #(my_bus_transaction) configure_seq;
    random_data_sequence #(my_bus_transaction) rndm_data_seq ;
    bus_sequence         #(my_bus_transaction) 
                                    list_of_sequences[string];

    uvm_report_info("ENV", "Starting");

    register_seq  = new();
    reset_seq     = new();
    configure_seq = new();
    rndm_data_seq = new();

    list_of_sequences["register_sequence"]    = register_seq;
    list_of_sequences["reset_sequence"]       = reset_seq;
    list_of_sequences["configure_sequence"]   = configure_seq;
    list_of_sequences["random_data_sequence"] = rndm_data_seq;

    // Run a bunch of addresses.
    b_seq = new();
    b_seq.start(sqr);

    // Run the register tests. A bunch of special sequences.
    foreach ( list_of_sequences[s] ) begin
      uvm_report_info("ENV", 
        $psprintf("Starting Sequence (%s)", s));
      list_of_sequences[s].start(sqr);
    end

    global_stop_request();
  endtask
endclass

module top;
  env env = new("env", null);

  initial
    run_test();
endmodule

