// Based on: https://www.edaplayground.com/x/Yk4N
module top();
  // Clock signal generation for the DUT
  reg clk = 0;

  // Clock generator: toggles the clock every 5 time units
  initial begin
    forever #5 clk = ~clk;
  end

  // Instantiate the interface with the clock signal
  dut_intf intf(clk);

  // Connect the DUT to the interface signals

  // VCD file generation for waveform analysis
  initial begin
    // Name of the dump file
    $dumpfile("verilog.vcd");
    // Dump all variables
    $dumpvars(0);
  end

  // Test program execution
  // Invoke the test case with the virtual interface
  test testcase(intf);
endmodule : top
