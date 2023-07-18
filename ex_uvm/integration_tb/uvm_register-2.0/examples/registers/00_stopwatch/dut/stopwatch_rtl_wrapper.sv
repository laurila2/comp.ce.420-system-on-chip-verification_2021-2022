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

// Import for uvm_report_info
import uvm_pkg::*;

typedef bit [31:0] ADDR_T;
typedef bit [31:0] DATA_T;

interface stopwatch_if(input bit clk);
    bit reset,    // If reset is ACTIVE, then 
                  //   the register is reset.
        count,    // If rwenable is NOT ACTIVE, and 
                  //   count is NOT ACTIVE, then no change 
                  //   in the value occurs.
                  // If rwenable is NOT ACTIVE, and 
                  //   count is ACTIVE, the we count 
                  //   either up or down on each clock edge.
        rwenable, // If rwenable is ACTIVE on the clock edge, 
                  // then either a READ or a WRITE will 
                  //   happen. See 'rw'.
        rw;       // If rwenable is 1 and rw is 1, 
                  //   READ:
                  //     data_o = mem[addr]
                  // If rwenable is 1 and rw is 0, 
                  //   WRITE:
                  //     mem[addr] = data_i

    DATA_T data_i; // Value WRITTEN. 
                   //  data_i written to REGISTER[addr] 
                   //   (when rwenable ACTIVE, rw = 0).
    DATA_T data_o; // Value READ. 
                   //  data_o read from REGISTER[addr] 
                   //   (when rwenable ACTIVE, rw = 1).
    ADDR_T addr;   // Address bits for writing and 
                   //  reading the registers.

    task read(ADDR_T l_addr, output DATA_T l_data);
      uvm_report_info($psprintf("%m"), 
        $psprintf("READ(%6x)", l_addr));
      addr = l_addr;
      rwenable = 1;
      count = 0;
      rw = 1;
      @(posedge clk);
      @(posedge clk);
      l_data = data_o;
      rwenable = 0;
      count = 1;
      uvm_report_info($psprintf("%m"), 
        $psprintf("READ(%6x) got %6x", l_addr, l_data));
    endtask

    task write(ADDR_T l_addr, DATA_T l_data);
      uvm_report_info($psprintf("%m"), 
        $psprintf("WRITE(%6x, %6x)", l_addr, l_data));
      addr = l_addr;
      data_i = l_data;
      rwenable = 1;
      count = 0;
      rw = 0;
      @(posedge clk);
      @(posedge clk);
      rwenable = 0;
      count = 1;
    endtask

    task pause_counting();
      count = 0;
    endtask

    task resume_counting();
      count = 1;
    endtask

    // Cause the stopwatch to print to STDOUT
    task debug();
      addr = 0;
      rwenable = 1;
      rw = 1;
      @(posedge clk);
      rwenable = 0;
    endtask

    task do_reset();
      data_i = 0;
      addr = 0;
      rwenable = 0;
      count = 0;
      reset = 1;
      @(posedge clk);
      reset = 0;
      count = 1; // Normal mode. Counting.
    endtask

    task count1();
      @(posedge clk);
    endtask

endinterface

module stopwatch_wrapper(stopwatch_if sw_if);
 stopwatch sw(
   .clk(sw_if.clk),
   .reset(sw_if.reset),
   .count(sw_if.count),
   .rwenable(sw_if.rwenable),
   .rw(sw_if.rw),
   .addr(sw_if.addr),
   .data_i(sw_if.data_i),
   .data_o(sw_if.data_o));
endmodule
