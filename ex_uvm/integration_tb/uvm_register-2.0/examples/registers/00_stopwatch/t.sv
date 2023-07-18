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

// The automatically generated register description.
import stopwatch_register_pkg::*;

`include "util.svh"

//
// Custom built code to translate between classes
//  and pin wiggles
//
//  bus_request --> DUT pin wiggles --> bus_response
//
class auto_test
  #(type REQ = uvm_sequence_item, 
    type RSP = uvm_sequence_item)
  extends uvm_register_auto_test #(REQ, RSP); 

  function new(string name, uvm_component p);
    super.new(name, p);
  endfunction

  //
  // Step 1: Define how this object connects
  //         to the DUT
  //
  virtual interface stopwatch_if sw_if[1:2];

  function void assign_vi( 
    virtual interface stopwatch_if sw_if_1,
    virtual interface stopwatch_if sw_if_2);
    sw_if[1] = sw_if_1;
    sw_if[2] = sw_if_2;
  endfunction

  //
  // Step 2: Define how a request and response
  //         is handled. And how the
  //         request and response is interfaced
  //         with the DUT.
  //
  task do_operation(REQ req, output RSP rsp);
    int chunk;
    bit[31:0] mapped_address;
 
    // Create a response.
    rsp = new();
    rsp.copy_req(req);
    rsp.set_id_info(req);
    rsp.status = PASS; // Default is PASS.
 
    uvm_report_info("AutoTest MEMREQ", req.convert2string());
 
    // Do the simple address mapping here.
    //  Each 1000 bytes is one chunk
    //
    //  Note: Each virtual interface above manages
    //        one chunk. So each virtual interface
    //        hangs a device for an address space 
    //        of 'h1000
    chunk = req.address / 'h1000;
    mapped_address = req.address % 'h1000;
    assert((chunk==1)||(chunk==2)) else
      $fatal(2, "chunk failed");
 
    // Actually "execute" the transaction.
    case (req.op)
      READ:  sw_if[chunk].read(mapped_address,  rsp.data);
      WRITE: sw_if[chunk].write(mapped_address, req.data);
    endcase
    uvm_report_info("AutoTest MEMRSP", rsp.convert2string());
  endtask
endclass

//
// The environment
//  contains 
//    1. a register environment
//    2. a translator between class-based 
//       transactions and pin wiggles
//
class my_env 
  extends uvm_env;

  uvm_register_env register_env;

  auto_test #(bus_request, bus_response) 
    m_auto_test;

  uvm_register_bus_monitor #(bus_response) 
    m_bus_monitor;

  function new(string name, uvm_component p);
    my_report_server my_report_server;
    //uvm_global_report_server gs;

    super.new(name, p);
    register_env = new("register_env", this);
    m_auto_test = new("auto_test", this);
    m_bus_monitor = new("bus_monitor", this);

    // Make my report server!
    my_report_server = new();
    my_report_server.name_width = 28;
    my_report_server.id_width = 20;
    // Hook it up.
    //gs = get_server();
    //gs.set_server(my_report_server);
    m_rh.m_glob.set_server(my_report_server);
  endfunction

  function void build();
    set_config_int("*", "count", 0);
    set_config_string("*",
      "default_auto_register_test",
      "register_sequence_all_registers#(REQ, RSP)");
    // Turn on the automatic register test system.
    set_config_int("*", "auto_run", 1);
  endfunction

  // Called from the top-level module to
  //  connect to the real interface.
  function void assign_vi(
    virtual interface stopwatch_if sw_if_1,
    virtual interface stopwatch_if sw_if_2);
    m_auto_test.assign_vi(sw_if_1, sw_if_2);
  endfunction

  function void connect();
    register_env.bus_transport_port.connect(
      m_auto_test.transport_export);
    m_auto_test.ap.connect(
      m_bus_monitor.analysis_export);
    m_bus_monitor.ap.connect(
      register_env.bus_rsp_analysis_export);
  endfunction

  function void report();
    uvm_register_map register_map;
    // Some general debug routines.
    // Useful for debug, but for normal regressions
	// printing object ids, etc aren't helpful
	// (too many opportunities to mismatch).
	//   m_auto_test.print();
    register_env.m_register_map.display_address_map();
  endfunction

  task run();
    #10000;
    global_stop_request();
  endtask
endclass

module top;
  bit clk = 0;

  // Our hardware
  // There are two instances of the hardware, and
  // each has its own interface.
  stopwatch_if sw_if_1(clk);
  stopwatch_if sw_if_2(clk);

  // The hardware instances.
  stopwatch_wrapper sw1(sw_if_1);
  stopwatch_wrapper sw2(sw_if_2);

  // The testbench environment
  my_env env = new("env", null);

  initial begin
    // Connect the class based testbench
    //  to the hardware.
    env.assign_vi(sw_if_1, sw_if_2);

    // Turn off the automatic running of the
    // register test. If you do this, then this
    // example doesn't do anything.
    //  set_config_int("*", "auto_run", 0);
`ifdef INCA
	// Note: Auto_load suffers from ordering differences between
	//       Questa and INCA.
	void'(register_map_auto_load::build_register_map());
`endif

    // Run the test
    run_test();
  end

  // Hardware clock
  always 
    #10 clk = ~clk;
endmodule
