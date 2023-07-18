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

// a simple memory that implements the simple_bus interface

module dut(simple_bus_interface simple_bus_if);
   class register;
      bit [31:0] addr;
      bit [31:0] data;

      function new(bit [31:0] a, bit [31:0] d);
         addr = a;
         data = d;
      endfunction
   endclass

   register registers[bit[31:0]];
   
   initial
     forever
       begin
          register hit;
          
          @(posedge simple_bus_if.clk);

          hit = null;
          if ( registers.exists(simple_bus_if.addr) )
            hit = registers[simple_bus_if.addr];
          
          if (simple_bus_if.wr === 1)
            if (hit != null)
              hit.data = simple_bus_if.data;
            else
              registers[simple_bus_if.addr] = 
                new(simple_bus_if.addr, simple_bus_if.data);
          else if (simple_bus_if.wr === 0)
            begin              
               if (hit != null)
                 simple_bus_if.data <= hit.data;
               else
                 simple_bus_if.data <= 'z;

               @(posedge simple_bus_if.clk);
            end
        end
endmodule
