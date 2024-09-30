// Based on: https://www.edaplayground.com/x/Yk4N
program test(cpu_if intf);
  // Instantiate the environment and pass the virtual interface to it
  environment env = new(intf);

  // Initial block to control the test execution
  initial begin
    // Reset the DUT through the driver
    env.drvr.reset();
    // Write 10 values
    env.drvr.write(10);
    // Read 10 values
    env.drvr.read(10);
  end
endprogram : test
