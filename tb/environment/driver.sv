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
    $display("Executing Reset\n");
    intf.HLT     = 0;
    intf.IRQ     = 0;
    intf.IDATA   = 0;
    intf.DATAI   = 0;
    intf.ESIMREQ = 0;
    @ (negedge intf.clk);
    intf.RES     = 1;
    @ (negedge intf.clk);
    intf.RES     = 0;
  endtask : reset

  // Write task: Generates random instructions. Could be constrained (valid ones) or completely random (not valid RISC-V instructions)
  task write(input integer iteration, input bit valid_inst);
    repeat (iteration) begin
      sti = new();
      @ (negedge intf.clk);
      if(sti.randomize()) begin // Generate stimulus
        $display("Driving instruction 0x%0h\n", sti.riscv_inst);
      end
      else begin
        $error("There was an error in randomize call of write task at %m")
      end
        intf.IDATA = sti.riscv_inst;
        intf.DATAI = sti.riscv_data;
        sb.instruction_queue.push_front(sti.riscv_inst); // Store the current instruction input in the scoreboard queue for that purpose
        sb.data_queue.push_front(sti.riscv_inst);        // Store the current data input in the scoreboard queue for that purpose
    end
    @ (negedge intf.clk);
    // TODO: what values to drive in "IDLE" mode?
  endtask : write

  // halt_pattern task: Drive HLT input with a delay pattern
  task halt_pattern();
    //TODO:
  endtask

  // interrupt_req task: request an interrupt to RISC-V core
  task interrupt_req();
    $display("New interrupt request\n");
    @ (negedge intf.clk);
    intf.IRQ = 1;
    @ (negedge intf.clk);
    intf.IRQ = 0;
  endtask

  // end_simulation_req task: Let the DUT that simulation will end soon. Just a debug capability that was added on DarkRISCV
  task end_simulation_req();
    $display("Simulation end request\n");
    @ (negedge intf.clk);
    intf.ESIMREQ = 1;
  endtask

endclass : driver
