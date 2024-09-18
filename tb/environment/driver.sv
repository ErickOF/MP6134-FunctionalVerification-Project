// Based on: https://www.edaplayground.com/x/Yk4N
class driver;
  // Instance of stimulus class to generate random values
  stimulus sti;

  // Instance of scoreboard class to store expected results
  scoreboard sb;

  // Virtual interface to interact with the DUT
  virtual dut_intf intf;

  // Constructor: Initializes the interface and scoreboard objects
  function new(virtual dut_intf intf, scoreboard sb);
    this.intf = intf;
    this.sb = sb;
  endfunction : new

  // Reset task: Initializes the DUT by resetting all control and data signals
  task reset();
  endtask : reset

  // Write task: Generates random values and drives them to the DUT
  task write(input integer iteration);
  endtask : write

  // Read task: Reads data from the DUT for a given number of iterations
  task read(input integer iteration);
  endtask : read
endclass : driver
