// ----------------------------------------------------------------------------
// dut_if.if
// ----------------------------------------------------------------------------
// DUT interface
// Physical pins that are connected to DUT
// ----------------------------------------------------------------------------
// Note: Using logic to allow 4-state values
// ----------------------------------------------------------------------------

interface dut_if(input bit clk);

  logic         rst_n;
  logic [31:0]  data_to_DUT;
  logic         we_out;
  logic         re_out;
  logic [31:0]  data_from_DUT;
  logic         full_in;
  logic         one_p_in;
  logic         empty_in;
  logic         one_d_in;

endinterface: dut_if
