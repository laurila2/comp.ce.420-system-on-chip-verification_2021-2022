// ----------------------------------------------------------------------------
// dut_axi_if.if
// ----------------------------------------------------------------------------
// DUT AXI interface
// Instantiates the three AXI channels that are connected to DUT
// ----------------------------------------------------------------------------

interface axi_if #(parameter data_width_g = 32) (input bit clk, rst_n);
  
  axi_channel #(.data_width_g(data_width_g)) waddr_channel();
  axi_channel #(.data_width_g(data_width_g)) wdata_channel();
  axi_channel #(.data_width_g(2))            wresp_channel();
  
endinterface: axi_if
