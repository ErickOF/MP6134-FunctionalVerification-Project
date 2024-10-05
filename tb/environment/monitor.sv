// Based on: https://www.edaplayground.com/x/Yk4N
`define MONITOR_NAME "MONITOR"

class monitor;
  import instructions_pkg::*;

  // Reference to the scoreboard to fetch expected values
  scoreboard sb;

  // Virtual interface to observe signals from the DUT
  virtual darkriscv_if intf;

  // Instruction and data from scoreboard and interface
  instruction_t instruction_sb;
  instruction_t instruction_intf;
  logic [31:0] data_sb;
  logic [31:0] data_intf;
  inst_type_e opcode;

  // PASS/ERROR counters
  int pass_counter;
  int error_counter;

  // Constructor: Initializes the interface and scoreboard objects
  function new(virtual darkriscv_if intf, scoreboard sb);
    this.intf = intf;
    this.sb = sb;
  endfunction : new

  // Check task: Continuously monitors the read enable signal and checks the data output
  task check();
    `PRINT_INFO(`MONITOR_NAME, "Check task running")
    pass_counter = 0;
    error_counter = 0;

    forever begin
      // Check on clock posedge
      @(negedge intf.CLK);

      if ((intf.RES === 0) && (sb.instruction_queue.size() > 0)) begin
        instruction_sb = sb.instruction_queue.pop_back();
	instruction_intf = intf.IDATA;
        data_sb = sb.data_queue.pop_back();
        data_intf = intf.IDATA;
	opcode = instruction_sb.opcode.opcode;

	`PRINT_INFO(`MONITOR_NAME, $sformatf("Instruction from Scoreboard: 0x%0h", instruction_sb))
	`PRINT_INFO(`MONITOR_NAME, $sformatf("Instruction from Interface: 0x%0h", instruction_intf))

	if (instruction_sb === instruction_intf) begin
	  `PRINT_INFO(`MONITOR_NAME, "Scoreboard and interface instructions match")
	  pass_counter++;
	end
	else begin
	  `PRINT_ERROR(`MONITOR_NAME, "Scoreboard and interface instructions mismatch")
	  error_counter++;
	end

	// Check instruction type
	`PRINT_INFO(`MONITOR_NAME, $sformatf("Instruction of type \"%s\"", opcode.name()))

	if (opcode == r_type) begin
	  check_r_type();
        end
	else if (opcode == i_type) begin
	  check_i_type();
	end

	$display();

        `PRINT_INFO(`MONITOR_NAME, $sformatf("Data input from Scoreboard: 0x%0h", data_sb))
	`PRINT_INFO(`MONITOR_NAME, $sformatf("Data input from Interface: 0x%0h", data_intf))

	if (data_sb == data_intf) begin
	  `PRINT_INFO(`MONITOR_NAME, "Scoreboard and interface input data match")
	  pass_counter++;
	end
	else begin
	  `PRINT_INFO(`MONITOR_NAME, "Scoreboard and interface input data mismatch")
	  error_counter++;
	end

        $display();
      end
    end
  endtask : check

  task check_i_type();
    `PRINT_INFO(`MONITOR_NAME, "Checking \"i_type\" instruction")
  endtask : check_i_type

  task check_r_type();
    `PRINT_INFO(`MONITOR_NAME, "Checking \"r_type\" instruction")
  endtask : check_r_type
endclass : monitor
