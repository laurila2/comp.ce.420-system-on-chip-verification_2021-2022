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
module stopwatch(
    input bit clk, 
              reset,   // If reset is ACTIVE, then 
                       //   the register is reset.
              count,   // If rwenable is NOT ACTIVE, 
                       //   and count is ACTIVE,
                       //   then now change in the 
                       //   value occurs.
                       // If rwenable is NOT ACTIVE, 
                       //   and count is NOT ACTIVE,
                       //   the we count either up 
                       //   or down on each clock edge.
              rwenable,// If rwenable is ACTIVE on 
                       //   the clock edge, 
                       //   then a new value will 
                       //   be rwenable from 'data_i'.
              rw,      // If rwenable is active AND
                       //    if rw = 1 => READ, 
                       //    if rw = 0 => WRITE
    input  bit[31:0] data_i,  // Value to rwenable 
                              //   when rwenable is ACTIVE.
    input  bit[31:0] addr,    // Address of the register 
                              //   to read or write.
    output bit[31:0] data_o); // Value of the register.

  bit [31:0] value_o;         // Scratch Register.

`define N_REGISTERS 8

  // Registers.
  bit [31:0] value;       // Value Register.      (REGISTER1)
  bit [31:0] reset_value = 0; // Value to reset to.(REGISTER2)
  bit [31:0] upper_limit; // Upper limit Register.(REGISTER3)
  bit [31:0] lower_limit; // Lower limit Register.(REGISTER4)

  struct packed {
    bit [3:0] stride;
    bit updown;
    bit upper_limit_reached;
    bit lower_limit_reached;
  } csr;                      // Control and Status 
                              //   Register.      (REGISTER5)

  // Some Memory.
  bit[31:0] memory[`N_REGISTERS];  // Some memory (REGISTER6)
                                   //             (.........)
                                   //             (REGISTER13)

  assign data_o = value_o;

  // Debug
  function void dump();
    $display("%m - Stopwatch DUMP");

    $display(" 1: %8h(%0d) %8h(%0d) %8h(%0d) %8h(%0d)",
      value, value, 
      reset_value, reset_value, 
      upper_limit, upper_limit, 
      lower_limit, lower_limit);

`ifdef INCA
    $display("    %2h(%0x)", csr, csr);
`else
    $display("    %2h(%p)", csr, csr);
`endif
     
    $display(" 6: %8h %8h %8h %8h", 
      memory[0], memory[1], memory[2], memory[3]); 
    $display("10: %8h %8h %8h %8h", 
      memory[4], memory[5], memory[6], memory[7]); 
  endfunction

  always @(posedge reset) begin
    value = reset_value;
    csr.updown = 1;
    csr.stride = 1;
    csr.upper_limit_reached = 0;
    csr.lower_limit_reached = 0;
    lower_limit = 10;
    upper_limit = 14;
    value = lower_limit;
    value_o = value;
  end

  function void check_value();
    if ( value > upper_limit ) begin
      value = upper_limit;
      csr.upper_limit_reached = 1;
    end
    else
      csr.upper_limit_reached = 0;

    if ( value < lower_limit ) begin
      value = lower_limit;
      csr.lower_limit_reached = 1;
    end
    else
      csr.lower_limit_reached = 0;
  endfunction

  always @(posedge clk) begin
    if ( !reset )
      if ( rwenable ) begin : rwenable_block
        if (rw) // READ ------------------------------
          case (addr) 
            0: dump(); 
            1: value_o = value;
            2: value_o = reset_value;
            3: value_o = upper_limit;
            4: value_o = lower_limit;
            5: value_o = csr;
            6,7,8,9,10,11,12,13: 
               value_o = memory[addr-6];
           14, 15: 
               $display(
                 "Error (%m) ADDR=%0x - RESERVED ADDRESS", 
                 addr);
           default:
               $display(
                 "Error (%m) ADDR=%0x - ADDRESS NOT MAPPED", 
                 addr);
         endcase
       else    // WRITE -------------------------------
          case (addr) 
            0: dump(); 
            1: //value = data_i;        // Read-only register.
               $display(
                 "Error (%m) - ADDR=%0x - Value is READ-ONLY",
                 addr);
            2: reset_value = data_i;
            3: upper_limit = data_i;
            4: lower_limit = data_i; 
            5: // Bits 0,1 read-only.
               csr = (data_i & 7'b1111_1_0_0 ) | csr[1:0];
            6,7,8,9,10,11,12,13: 
               memory[addr-6] = data_i;
           14, 15: 
               $display(
                 "Error (%m) ADDR=%0x - RESERVED ADDRESS", 
                 addr);
           default:
               $display(
                 "Error (%m) ADDR=%0x - ADDRESS NOT MAPPED", 
                 addr);
         endcase
      end : rwenable_block

      else if ( count ) begin : count_block
        csr.upper_limit_reached = 0;
        csr.lower_limit_reached = 0;
        if ( csr.updown == 1'b1 ) begin
          value += csr.stride;
          if ( value == upper_limit )
             csr.upper_limit_reached = 1;
          if ( value > upper_limit ) begin
             value = lower_limit + (value - upper_limit - 1);
          end
        end
        else begin
          value -= csr.stride;
          if ( value == lower_limit )
             csr.lower_limit_reached = 1;
          if ( value < lower_limit ) begin
             value = upper_limit - (lower_limit - value - 1);
          end
        end
        value_o = value;
      end : count_block
    #0;
  end
endmodule
