// Based on: https://www.edaplayground.com/x/Yk4N

`define TEST_NAME "TEST"

program test(darkriscv_if intf);
  // Instantiate the environment and pass the virtual interface to it
  environment env = new(intf);

  // Initial block to control the test execution
  initial begin
    // Reset the DUT through the driver
    env.drvr.reset();
    // Initialize registers
    env.drvr.init_registers();
    // Write 10 values
    env.drvr.write(10, 1);

    // Check if the test pass
    if (env.mntr.pass_counter == 0) begin
      `PRINT_WARNING(`TEST_NAME, "None of the checkers run")
    end
    else if (env.mntr.error_counter > 0) begin
      `PRINT_ERROR(`TEST_NAME, $sformatf("Monitor error count: %d", env.mntr.error_counter))
    end
    else begin
      `PRINT_INFO(`TEST_NAME, "Test passed")
    end
  end
endprogram : test
