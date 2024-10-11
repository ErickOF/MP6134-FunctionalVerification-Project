// Based on: https://www.edaplayground.com/x/Yk4N
class environment;
  // Objects for driver, scoreboard, and monitor
  driver drvr;
  scoreboard sb;
  monitor mntr;
  riscv_reference_model ref_model;

  // Checkers
  b_type_checker b_type_check;
  i_type_checker i_type_check;
  j_type_checker j_type_check;
  r_type_checker r_type_check;
  s_type_checker s_type_check;
  u_type_checker u_type_check;

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

    // Instantiate the checkers and pass the interface and scoreboard references
    b_type_check = new("B_TYPE_CHECKER", intf, sb);
    i_type_check = new("I_TYPE_CHECKER", intf, sb);
    j_type_check = new("J_TYPE_CHECKER", intf, sb);
    r_type_check = new("R_TYPE_CHECKER", intf, sb);
    s_type_check = new("S_TYPE_CHECKER", intf, sb);
    u_type_check = new("U_TYPE_CHECKER", intf, sb);

    // Start the monitor's checking process in a parallel thread
    fork 
      mntr.check();
      ref_model.wait_for_instructions();
    join_none

    // Start the checker's checking processes in a parallel thread
    fork
      b_type_check.check();
      i_type_check.check();
      j_type_check.check();
      r_type_check.check();
      s_type_check.check();
      u_type_check.check();
    join_none
  endfunction : new
endclass : environment
