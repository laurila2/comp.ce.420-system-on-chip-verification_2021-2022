
This example demonstrates using backdoor access.

-------------------
Exploring the files
-------------------

t.sv:

  The top level contains 3 instances of 2 pieces of hardware.
  dut_ABC is instanced twice, and dut_XYZ is instanced once.
  A "bus" is connected to them, and simulation begins.


dut_ABC.sv:
dut_XYZ.sv:

  The hardware is implemented in dut_ABC.sv and dut_XYZ.sv.
  The modules dut_ABC and dut_XYZ contain the same 
  implementation, except dut_XYZ has faulty reset code.

  Note that the hardware contains small "always" blocks
  which act as monitors. These are helpful debug aids, as
  they report the time and value whenever the registers
  change value.


test.sv:

  test.sv uses the register map to iterate each of the registers
  calling backdoor_write(), etc.

  The first thing that this test does is make sure the
  "HDL" names are correct for the registers. In this example,
  the HDL register names share a common suffix with the registers
  in the register file

    registers[i].set_dut_register_name(
      replace( "register_map.dual_map", 
               "top", 
               registers[i].get_full_name()));

  The call above uses 'set_dut_register_name()' to set the name of
  the register. (This is the HDL name). 
  
  In our case the name of the register 
     in the register file is "register_map.dual_map.r1" 
     in the DUT           is "top.r1" 


  The next thing the test does is use 'backdoor_write()' to write some
  value to the registers.
  Then the test reads those values back using 'backdoor_read()'.

      foreach (registers[i])
        registers[i].backdoor_write(i);
      ...
      foreach (registers[i])
        registers[i].backdoor_read(val_read);

  Next the test 'resets' the register and the hardware.

      foreach (registers[i])
        registers[i].reset();
      vi.reset();

  Once the system is reset, the test does a backdoor_read() to get 
  the value directly from the hardware. Then it compares the 
  value read with the value in the shadow. (Both should be the
  reset value).

  The following two statements implement this behavior:

        registers[i].backdoor_read(val_read);
        registers[i].bus_read32(val_read);


system_map_pkg.sv:

  system_map_pkg.sv builds the register map for the complete system,
  from the component register files from each hardware.


dut_ABC_rf_pkg.sv
dut_XYZ_rf_pkg.sv

  dut_ABC_rf_pkg.sv and dut_XYZ_rf_pkg.sv define the register files
  for their respective hardware. The register files for these two
  pieces of hardware is relatively the same. The only difference is
  that the register in dut_ABC is defined to have a reset value.


