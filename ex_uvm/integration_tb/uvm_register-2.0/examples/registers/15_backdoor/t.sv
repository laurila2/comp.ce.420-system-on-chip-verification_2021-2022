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

interface my_bus_i;
  bit r;

  task reset;
        r <= 0;
    #10 r <= 1;
    #10 r <= 0;
    #10;
  endtask
endinterface


import test_pkg::a_test;
import uvm_pkg::run_test;

module top;
  my_bus_i my_bus();

  dut_ABC dut1(my_bus);
  dut_XYZ dut2(my_bus);
  dut_ABC dut3(my_bus);

  a_test t = new("t", null);

  initial begin
    t.vi = my_bus;
    run_test();
  end
endmodule

