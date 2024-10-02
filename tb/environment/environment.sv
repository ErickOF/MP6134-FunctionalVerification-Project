// Based on: https://www.edaplayground.com/x/Yk4N
class environment;
  // Objects for driver, scoreboard, and monitor
  driver drvr;
  scoreboard sb;
  monitor mntr;
  riscv_reference_model ref_model;

  // Virtual interface to connect the environment components to the DUT signals
  virtual darkriscv_if intf;

  // Constructor: Initializes the environment
  function new(virtual darkriscv_if intf);
    // Display message indicating the creation of the environment
    $display("Creating environment");

    // Assign the virtual interface
    this.intf = intf;

    ref_model = new();

    // Instantiate the scoreboard
    sb = new();

    // Instantiate the driver and pass the interface and scoreboard references
    drvr = new(intf, sb, ref_model.mb_mn_instr);

    // Instantiate the monitor and pass the interface and scoreboard references
    mntr = new(intf, sb);

    // Start the monitor's checking process in a parallel thread
    fork 
      mntr.check();
      ref_model.wait_for_instructions();
    join_none
  endfunction : new
endclass : environment
