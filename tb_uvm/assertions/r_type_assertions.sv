module r_type_assertions(darkriscv_if intf);
  //-----------------------------------------------------------------------------------------------
  // Property: check_add
  //
  // Description:
  //   This property checks if the sum of two registers (r1 and r2) matches the value in `RMDATA`.
  //   It is designed for verifying an ADD-type instruction in the DUT. The registers are
  //   identified based on the instruction data interface (`IDATA`), and the result is expected to
  //   be present in the `RMDATA` register after a small delay.
  //
  //
  // Notes:
  //   - This property is triggered on the positive edge of `intf.CLK`.
  //   - The property will be disabled if the reset signal (`RES`) is active, the flush signal
  //     (`FLUSH`) is non-zero, or if the instruction is not of the expected `r_type`.
  //   - If enabled, the property checks whether the sum of registers `r1` and `r2` matches the
  //     value in `RMDATA` after a 2-time unit delay.
  //-----------------------------------------------------------------------------------------------
  property check_add;
    // Declare two 32-bit registers to hold the values fetched from the DUT
    logic [31:0] r1, r2;

    // Triggered on the positive edge of the clock (`intf.CLK`)
    // The property will be disabled if reset (`RES`), flush (`FLUSH`), or the instruction type is
    // not an `r_type` (based on the instruction's opcode bits)
    @(posedge intf.CLK)
    disable iff (
      // Check if the DUT is in reset state
      intf.RES &&
      // Check if flush is not zero (flush state)
      (`HDL_TOP.FLUSH !== 0) &&
      // Check if the instruction is not `r_type`
      (intf.IDATA[6:0] !== r_type)
    )
    // The property will only proceed if the conditions above are not met
    // Fetch the values of registers `r1` and `r2` based on instruction data
    (r1 = `HDL_TOP.REGS[intf.IDATA[19:15]], 
     r2 = `HDL_TOP.REGS[intf.IDATA[24:20]])
    // After 2 time units, check if the sum of `r1` and `r2` matches `RMDATA`
    |-> #2 ((r1 + r2) === `HDL_TOP.RMDATA)
  endproperty

  //-----------------------------------------------------------------------------------------------
  // Property: check_sub
  //
  // Description:
  //   This property checks if the sum of two registers (r1 and r2) matches the value in `RMDATA`.
  //   It is designed for verifying an SUB-type instruction in the DUT. The registers are
  //   identified based on the instruction data interface (`IDATA`), and the result is expected to
  //   be present in the `RMDATA` register after a small delay.
  //
  //
  // Notes:
  //   - This property is triggered on the positive edge of `intf.CLK`.
  //   - The property will be disabled if the reset signal (`RES`) is active, the flush signal
  //     (`FLUSH`) is non-zero, or if the instruction is not of the expected `r_type`.
  //   - If enabled, the property checks whether the sum of registers `r1` and `r2` matches the
  //     value in `RMDATA` after a 2-time unit delay.
  //-----------------------------------------------------------------------------------------------
  property check_sub;
    // Declare two 32-bit registers to hold the values fetched from the DUT
    logic [31:0] r1, r2;

    // Triggered on the positive edge of the clock (`intf.CLK`)
    // The property will be disabled if reset (`RES`), flush (`FLUSH`), or the instruction type is
    // not an `r_type` (based on the instruction's opcode bits)
    @(posedge intf.CLK)
    disable iff (
      // Check if the DUT is in reset state
      intf.RES &&
      // Check if flush is not zero (flush state)
      (`HDL_TOP.FLUSH !== 0) &&
      // Check if the instruction is not `r_type`
      (intf.IDATA[6:0] !== r_type)
    )
    // The property will only proceed if the conditions above are not met
    // Fetch the values of registers `r1` and `r2` based on instruction data
    (r1 = `HDL_TOP.REGS[intf.IDATA[19:15]], 
     r2 = `HDL_TOP.REGS[intf.IDATA[24:20]])
    // After 2 time units, check if the sum of `r1` and `r2` matches `RMDATA`
    |-> #2 ((r1 - r2) === `HDL_TOP.RMDATA)
  endproperty

  assert_check_operation: assert property (check_add);
  assert_check_operation: assert property (check_sub);

  cover_check_operation: cover property(check_add);
  cover_check_operation: cover property(check_sub);
endmodule : r_type_assertions
