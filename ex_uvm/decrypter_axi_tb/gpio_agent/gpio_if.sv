// ----------------------------------------------------------------------------
// gpio_if.if
// ----------------------------------------------------------------------------
// DUT interface
// Physical pins that are connected to DUT
// ----------------------------------------------------------------------------
// Note: Using logic to allow 4-state values
// ----------------------------------------------------------------------------

interface gpio_if #(parameter data_width_g = 32) ();

    logic valid;
    logic [data_width_g-1:0] decrypted;
  
endinterface: gpio_if
