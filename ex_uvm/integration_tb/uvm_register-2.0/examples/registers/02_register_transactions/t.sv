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

class my_register_driver 
  #(type REQ = uvm_register_transaction, 
    type RSP = uvm_register_transaction)
  extends uvm_driver #(REQ, RSP);

  function new(string name, uvm_component p);
    super.new(name, p);
  endfunction

  task run();
    uvm_report_info("My Register Driver",
      $psprintf("Starting Register Driver (%s)...",
        get_full_name()));

    forever begin
      // Collect the request
      seq_item_port.get(req);
      uvm_report_info("Register Driver",
        $psprintf("  request (%s)...",
          req.convert2string()));

      uvm_report_info("Register Driver",
        "Wiggling Registers....");
      #10; // Wiggling takes time...

      rsp = new();
      rsp.copy_req(req);
      rsp.status = PASS;
      rsp.set_id_info(req);

      uvm_report_info("Register Driver",
        $psprintf(" response (%s)...",
          rsp.convert2string()));

      // Transfer the response back
      rsp_port.write(rsp);
    end
  endtask
endclass

class env extends uvm_env;
  my_register_driver     
    #(uvm_register_transaction) m_driver; 
  uvm_register_sequencer 
    #(uvm_register_transaction) m_sequencer;

  register_sequence_all_registers 
    #(uvm_register_transaction, uvm_register_transaction) 
      r_seq;

  function new(string name, uvm_component p);
    super.new(name, p);
  endfunction

  function void build();
    super.build();
    m_driver    = new("m_driver",    this);
    m_sequencer = new("m_sequencer", this);

    set_config_int("*", "count", 0);
  endfunction

  function void connect();
    m_driver.seq_item_port.connect(
      m_sequencer.seq_item_export);
    m_driver.rsp_port.connect(     
      m_sequencer.rsp_export);
  endfunction

  task run();
    uvm_report_info("ENV", "Starting");
    r_seq = new();

    // Run the register test.
    r_seq.start(m_sequencer);
    #1000;

    global_stop_request();
  endtask
endclass

module top;
  env env = new("env", null);

  initial
    run_test();
endmodule

