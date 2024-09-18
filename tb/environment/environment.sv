// Based on: https://www.edaplayground.com/x/Yk4N
class environment;
  // Objects for driver, scoreboard, and monitor
  driver drvr;
  scoreboard sb;
  monitor mntr;

  // Virtual interface to connect the environment components to the DUT signals
  virtual dut_intf intf;

  // Constructor: Initializes the environment
  function new(virtual dut_intf intf);
    // Display message indicating the creation of the environment
    $display("Creating environment");

    // Assign the virtual interface
    this.intf = intf;

    // Instantiate the scoreboard
    sb = new();

    // Instantiate the driver and pass the interface and scoreboard references
    drvr = new(intf, sb);

    // Instantiate the monitor and pass the interface and scoreboard references
    mntr = new(intf, sb);

    // Start the monitor's checking process in a parallel thread
    fork 
      mntr.check();
    join_none
  endfunction : new
endclass : environment
