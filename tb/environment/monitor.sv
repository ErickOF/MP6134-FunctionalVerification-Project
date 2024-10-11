// Based on: https://www.edaplayground.com/x/Yk4N
class monitor;
  // Reference to the scoreboard to fetch expected values
  scoreboard sb;

  // Virtual interface to observe signals from the DUT
  virtual darkriscv_if intf;

  // Constructor: Initializes the interface and scoreboard objects
  function new(virtual darkriscv_if intf, scoreboard sb);
    this.intf = intf;
    this.sb = sb;
  endfunction : new

  // Check task: Continuously monitors the read enable signal and checks the data output
  task check();
    logic [31:0] instruction_data;
    logic [31:0] input_data;
    forever begin
      @ (posedge intf.CLK);
      if (!intf.HLT && !intf.RES) begin
        instruction_data = intf.IDATA;
        input_data = intf.DATAI;

        $display("Time: %0t, Instruction IDATA: %h, Input Data: %h", $time, instruction_data, input_data);
      end    
    end
  endtask : check
endclass : monitor
