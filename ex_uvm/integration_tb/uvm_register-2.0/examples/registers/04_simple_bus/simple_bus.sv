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

// a typical OVC that implements a very simple memory-like bus.

interface simple_bus_interface;
logic clk;
logic[31:0] addr = 'z;
logic[31:0] data = 'z;
logic wr = 'z;
endinterface

package simple_bus_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum {READ_op, WRITE_op} op_t;

// --- the bus transaction ---
class simple_bus_transaction extends uvm_sequence_item;
  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand op_t       rw;

  `uvm_object_utils_begin(simple_bus_transaction)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_enum(op_t, rw, UVM_ALL_ON)
  `uvm_object_utils_end
endclass


// --- The bus driver ---
// implements a very simple protocol.
// Write is executed in one cycle
// Read has an address cycle followed by a data cycle
// If no read or write is required I put the wr pin to 'z

class simple_bus_driver 
    extends uvm_driver#(simple_bus_transaction);

   simple_bus_transaction item;
 
   virtual simple_bus_interface vif;

   `uvm_component_utils(simple_bus_driver) 
 
   function new(string name, uvm_component p);
      super.new(name, p);
   endfunction
 
   task run();
      forever begin
         seq_item_port.try_next_item(item);

         if (item != null)
           begin
              vif.wr <= item.rw;
              vif.addr <= item.addr;
              vif.data <= 'z;

              if(item.rw == WRITE_op)
                begin
                   vif.data <= item.data;
                   // we provide responses for write as 
                   // well, but this is a matter of choice
                   seq_item_port.item_done(item);
                end

              @(posedge vif.clk);

              if(item.rw == READ_op)
                begin
                   vif.wr <= 'z;
                   vif.addr <= 'z;
                   @(posedge vif.clk);
                   item.data = vif.data;
                   seq_item_port.item_done(item);
                   #0; // TODO : if I don't have this 
                       // then I never get a back-to-back 
                       // transaction immidiately after read.
                end

           end
         else
           begin
              vif.wr <= 'z;
              vif.addr <= 'z;

              @(posedge vif.clk);
           end
      end
   endtask
endclass


// --- the bus sequencer ---
class simple_bus_sequencer 
    extends uvm_sequencer #(simple_bus_transaction);

   `uvm_sequencer_utils(simple_bus_sequencer)

   function new (string name, uvm_component parent);
      super.new(name, parent);
      `uvm_update_sequence_lib
   endfunction
endclass


// --- the bus monitor ---
class simple_bus_monitor extends uvm_monitor;
   virtual simple_bus_interface vif;

   uvm_analysis_port #(simple_bus_transaction) 
     bus_transactions_ap;

   simple_bus_transaction current_transaction;

   `uvm_component_utils(simple_bus_monitor)

    function new (string name, uvm_component parent);
       super.new(name, parent);
       bus_transactions_ap = new("bus_transactions_ap", this);
    endfunction

   task run();
      forever
        begin
           @(posedge vif.clk);

           if ((vif.wr === 0) || (vif.wr === 1))
             begin
                current_transaction = new();
                current_transaction.rw = op_t'(vif.wr);
                current_transaction.addr = vif.addr;
                current_transaction.data = vif.data;

                if (current_transaction.rw == READ_op)
                  begin
                     @(posedge vif.clk);
                     current_transaction.data = vif.data;
                  end

                bus_transactions_ap.write(current_transaction);
             end
        end
   endtask
endclass

// --- the bus agent ---
class simple_bus_agent extends uvm_agent;
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  simple_bus_driver    driver;
  simple_bus_sequencer sequencer;
  simple_bus_monitor   monitor;

  `uvm_component_utils_begin(simple_bus_agent)
    `uvm_field_enum(uvm_active_passive_enum, 
      is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    super.build();
    $cast(monitor, 
        create_component("simple_bus_monitor",   "monitor"));
    if(is_active == UVM_ACTIVE) begin
      $cast(driver,
        create_component("simple_bus_driver",    "driver"));
      $cast(sequencer, 
        create_component("simple_bus_sequencer", "sequencer"));
    end
  endfunction

  function void connect();
    super.connect();
    if(is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
      driver.rsp_port.connect(sequencer.rsp_export);
    end
  endfunction
endclass

// --- the bus base sequence ---
class simple_bus_base_seq 
    extends uvm_sequence#(simple_bus_transaction);

  `uvm_sequence_utils(simple_bus_base_seq, 
    simple_bus_sequencer)
 
  function new(string name = "simple_bus_base_seq");
    super.new(name);
  endfunction 

endclass

// --- the bus top level ---
class simple_bus_env extends uvm_env;

  virtual interface simple_bus_interface vif;

  simple_bus_agent agent;

  `uvm_component_utils(simple_bus_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build();
    super.build();
    $cast(agent, 
      create_component("simple_bus_agent", "agent"));
  endfunction


  function void assign_vi(
      virtual interface simple_bus_interface vif);

    this.vif          = vif; 
    agent.monitor.vif = vif;
    if (agent.is_active == UVM_ACTIVE)
      agent.driver.vif  = vif;
  endfunction
endclass

endpackage
