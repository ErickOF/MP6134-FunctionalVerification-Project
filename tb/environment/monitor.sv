// Based on: https://www.edaplayground.com/x/Yk4N
class monitor;
  // Reference to the scoreboard to fetch expected values
  scoreboard sb;

  // Virtual interface to observe signals from the DUT
  virtual dut_intf intf;

  // Constructor: Initializes the interface and scoreboard objects
  function new(virtual dut_intf intf, scoreboard sb);
    this.intf = intf;
    this.sb = sb;
  endfunction : new

  // Check task: Continuously monitors the read enable signal and checks the data output
  task check();
  endtask : check
endclass : monitor
