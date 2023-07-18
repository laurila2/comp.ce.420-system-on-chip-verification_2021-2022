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

package top_level_pkg;

import uvm_pkg::*;
// register package code
import uvm_register_pkg::*;
// register definitions
import stopwatch_register_pkg::*;
// simple bus model
import simple_bus_pkg::*;

`include "uvm_macros.svh"

// used in order to pass the simple 
// bus interface through a configuration object
class interfaces_container extends uvm_object;

    virtual interface simple_bus_interface  simple_bus_vif; 

    function new(string name = "interfaces_container" );
       super.new(name);
    endfunction

    virtual function uvm_object create(
        string name = "interfaces_container" );  
      interfaces_container tmp = new();
      return tmp;
    endfunction
      
    function void do_copy( uvm_object rhs);
      interfaces_container tmp;
      tmp = interfaces_container'(rhs);
      simple_bus_vif = tmp.simple_bus_vif;
    endfunction
endclass

// our own register sequence
// writes random data to one of the registers 
// and then reads it back and compares it to the original
class write_read_csr_seq 
    extends uvm_register_sequence_base 
      #(uvm_register_transaction, 
        uvm_register_transaction);

   `uvm_sequence_utils(write_read_csr_seq, 
     uvm_register_sequencer#(REQ, RSP))

   stopwatch_csr csr_reg;
   uvm_register_transaction reg_trans;
       
   function new(string name = "write_read_csr_seq");
      super.new(name);
   endfunction
   
   // These helper functions create the register 
   //  transaction, fill it with the required 
   //  data and send it
   task write_reg(uvm_register_base r);
      uvm_register_transaction rsp;
      
      `uvm_create(reg_trans)
      reg_trans.data = r.get_data32();
      reg_trans.name = r.get_name();
      reg_trans.op = WRITE;
      `uvm_send(reg_trans)
      get_response(rsp);      
   endtask // write_reg

   task read_reg(uvm_register_base r);
      uvm_register_transaction rsp;
      
      `uvm_create(reg_trans)
      reg_trans.name = r.get_name();
      reg_trans.op = READ;
      `uvm_send(reg_trans)
      get_response(rsp);
      r.set_data32(rsp.data);
   endtask
   
   task body();
      bit[31:0] write_data, read_data;
      
      uvm_report_info("write_read_csr_seq", "Starting...");
      // create the register and randomize it
      // the name should point to the instance 
      //  we want to read/write
      csr_reg = new("register_map.sw1.CSR", null); 
      if(!(csr_reg.randomize() with { 
        csr_reg.data.stride == 3; }))
        uvm_report_error("RANDOMIZATION FAILUE", 
                         "randomization failed");

      write_data = csr_reg.get_data32();
      
      write_reg(csr_reg);
      read_reg(csr_reg);

      read_data = csr_reg.get_data32();

      if (write_data != read_data)
        uvm_report_error("READ WRITE MISMATCH", 
"Data read from CSR reg is not identical to the data written");
   endtask    
endclass
    
// This sequence pulls register transactions from 
// the register sequencer through the uvm_tlm_transport_channel
// It then translates each of these transactions 
// into a simple bus transaction and sends 
// it to the simple bus driver
class translate_seq extends simple_bus_base_seq;

   `uvm_sequence_utils(translate_seq, simple_bus_sequencer)
   
   simple_bus_transaction simple_bus_req, simple_bus_rsp;
   bus_request bus_req;
   bus_response bus_rsp;
   
   // a pointer to a port which should be connected 
   // to the register sequencer output and 
   // initalized when this sequence is created
   uvm_tlm_transport_channel #(bus_request, bus_response) 
     bus_channel_i;

   function new(string name = "translate_seq");
      super.new(name);
   endfunction 
   
   task body();  
      // if this sequence was created automatically 
      //  by the factory, just return immediately
      if (bus_channel_i == null) return; 
    
      forever
        begin
           bus_req = new();
           bus_rsp = new();        
           simple_bus_rsp = new();
           
           bus_channel_i.get_request_export.get(bus_req);
           
           `uvm_create(simple_bus_req)
             
           simple_bus_req.addr = bus_req.address;
           simple_bus_req.data = bus_req.data;
           simple_bus_req.rw = op_t'(bus_req.op);
           
           `uvm_send(simple_bus_req)
           get_response(simple_bus_rsp);
           
           bus_rsp.address = simple_bus_rsp.addr;
           bus_rsp.data = simple_bus_rsp.data;
           bus_rsp.op = op_code_t'(simple_bus_rsp.rw);
           
           bus_channel_i.put_response_export.put(bus_rsp);
        end
   endtask
endclass

// This class is used to translate the simple 
// bus transactions coming from the simple 
// bus monitor into register transactions
// It preforms the same role as the 
// translate sequence for the generator.
class reg_pkg_simple_bus_adapter 
    extends uvm_subscriber#(simple_bus_transaction);

   `uvm_component_utils(reg_pkg_simple_bus_adapter)

   uvm_analysis_port #(uvm_register_transaction) ap;

   uvm_register_map register_map;

   function new(string name, uvm_component p);
      super.new(name, p);
      ap = new("ap", this);
   endfunction
   
   function void build();
      super.build();
      register_map = 
        uvm_register_map::uvm_register_get_register_map();
   endfunction
   
   // This function does the actual translation 
   // from simple bus transactions into register transactions
   virtual function void write(simple_bus_transaction t);
      uvm_register_base r;
      
      uvm_register_transaction register_transaction = new();
      
      r = register_map.lookup_register_by_address(t.addr);
     
      register_transaction.name = r.get_full_name();
      register_transaction.data = t.data;
      register_transaction.op = op_code_t'(t.rw);

      // The output register transaction published on the 
      // analysis port, 'ap'.
      ap.write(register_transaction);
  endfunction
endclass


// instantiate the simple bus env and the register env.
// configures the register sequence to our register sequence
// starts the translation sequence

class top_level_env extends uvm_env;

    interfaces_container interfaces_container_i;

   `uvm_component_utils_begin(top_level_env)
     `uvm_field_object(interfaces_container_i, UVM_ALL_ON)
   `uvm_component_utils_end

   simple_bus_env simple_bus_env_i;  
   uvm_register_env register_env_i;
   reg_pkg_simple_bus_adapter adapter_i;
   
   // a pointer to a port which should be connected 
   // to the register sequencer output and 
   // initalized when this sequence is created
   uvm_tlm_transport_channel #(bus_request, bus_response) 
     bus_channel_i;

   function new(string name, uvm_component p);
      super.new(name, p);
   endfunction

   function void build();
      super.build();
       
      set_config_string("register_env_i.sequencer", 
                         "default_sequence", 
                          "write_read_csr_seq");
     
      simple_bus_env_i = new("simple_bus_env_i", this);
      register_env_i   = new("register_env_i",   this);
      bus_channel_i    = new("bus_channel_i",    this);
      adapter_i        = new("adapter_i",        this);

      // This makes sure the automatic register tests get 
      // started. (they are NOT started by default).
      //    1 means automatically start.
      //    0 means don't automatically start.
      set_config_int("*", "auto_run", 1);

      // This turns off the automatic starting of sequences 
      // from factories.
      // If you set count to non-zero, then the bus sequence
      // write_read_csr_seq will not be run (in this example).
      set_config_int("*", "count", 1);
   endfunction

   function void connect();
      super.connect();
      simple_bus_env_i.assign_vi(
        interfaces_container_i.simple_bus_vif);
      register_env_i.bus_transport_port.connect(
        bus_channel_i.transport_export);
      simple_bus_env_i.agent.monitor.bus_transactions_ap.connect(
        adapter_i.analysis_export);
      adapter_i.ap.connect(
        register_env_i.bus_rsp_analysis_export);
   endfunction

  task run();
     translate_seq translate_seq_i;

     translate_seq_i = new(); // creating this sequence 
                              // through the factory is 
                              // ugly, and actually not needed
     translate_seq_i.bus_channel_i = bus_channel_i;

	 factory.print();
     fork
       translate_seq_i.start(simple_bus_env_i.agent.sequencer);          
       #200000; // If we get to 100000 ticks, we're done. 
     join_any
     
     global_stop_request();
  endtask
endclass

// top level test that is specified in the command line
class default_test extends uvm_test;
   top_level_env top_level_env_i;
   
   `uvm_component_utils(default_test)

   function new(string name = "default_test", 
                uvm_component parent = null);
     super.new(name,parent);
   endfunction : new
     
   function void build();
     super.build();
     $cast(top_level_env_i, 
       create_component("top_level_env", "top_level_env_i"));
   endfunction   
endclass
endpackage

// top level module to instantiate 
// the interface, generate clock and start the test
module top;
   import uvm_pkg::*;
   import top_level_pkg::*;   

   simple_bus_interface simple_bus_interface_i();
   dut dut_i(simple_bus_interface_i);
   interfaces_container interfaces_container_i = new();

   // generate the simple bus clock
   bit clk = 0;

   assign simple_bus_interface_i.clk = clk;
   
   always begin
     #20;
     clk = ~clk;
   end
   
   initial begin      
     // send the interface as configuration object
     interfaces_container_i.simple_bus_vif = 
       simple_bus_interface_i;
     set_config_object("uvm_test_top.*", 
       "interfaces_container_i", interfaces_container_i);

     // start running
     run_test();
   end
endmodule
