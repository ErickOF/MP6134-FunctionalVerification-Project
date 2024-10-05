`define MONITOR_NAME "MONITOR"

//#################################################################################################
// Class: monitor
// Description: This class monitors the instructions and data of the DUT and compares them with the
//              expected values from  the scoreboard. It continuously checks signals on the virtual
//              interface and ensures the DUT operates correctly by comparing the scoreboard's
//              expected values with the DUT's actual output.
//
//              If mismatches occur, the monitor increments error counters apropriate messages.
//
//              It includes special checks for different instruction types (`r_type` and `i_type`).
//
// Parameters:
//  - intf: The virtual interface connected to the DUT.
//  - sb  : The scoreboard containing expected values for instructions and data.
//#################################################################################################
class monitor;
  // Import instruction types from the package
  import instructions_pkg::*;

  //###############################################################################################
  // Members:
  //###############################################################################################

  // Reference to the scoreboard to fetch expected values
  scoreboard sb;

  // Virtual interface to observe signals from the DUT
  virtual darkriscv_if intf;

  // Instruction and data from scoreboard and interface
  // Expected instruction from scoreboard
  instruction_t instruction_sb;
  // Actual instruction from DUT interface
  instruction_t instruction_intf;
  // Expected data from scoreboard
  logic [31:0] data_sb;
  // Actual data from DUT interface
  logic [31:0] data_intf;
  // Instruction opcode (enum)
  inst_type_e opcode;

  // PASS/ERROR counters to track matching/mismatched comparisons
  int pass_counter;
  int error_counter;

  //###############################################################################################
  // Constructor: new
  // Description: Initializes the monitor object with the virtual interface and scoreboard passed
  //              as parameters.
  //
  // Parameters:
  //  - intf: Virtual interface to observe signals from the DUT.
  //  - sb  : Scoreboard reference to fetch expected instruction and data values.
  //###############################################################################################
  function new(virtual darkriscv_if intf, scoreboard sb);
    this.intf = intf;
    this.sb = sb;
  endfunction : new

  //###############################################################################################
  // Task: check
  // Description: This task continuously monitors the DUT's signals on every negative edge of the
  //              clock. It compares the instructions and data from the scoreboard with those from
  //              the DUT.
  // 
  //              If there is a mismatch, the error counter is incremented, and an error message is
  //              printed. Otherwise, a pass message is shown.
  //
  //              Additionally, it checks the type of instruction (e.g., `r_type` or `i_type`) and
  //              calls specialized check functions for each type.
  //###############################################################################################
  task check();
    `PRINT_INFO(`MONITOR_NAME, "Check task running")
    
    // Initialize counters
    pass_counter = 0;
    error_counter = 0;

    // Infinite loop to continuously check the DUT
    forever begin
      // Check on negative edge of the clock
      @(negedge intf.CLK);

      // Ensure the reset is de-asserted and there are instructions in the scoreboard queue
      if ((intf.RES === 0) && (sb.instruction_queue.size() > 0)) begin
        // Fetch the instruction and data from the scoreboard and DUT interface
        instruction_sb = sb.instruction_queue.pop_back();
        instruction_intf = intf.IDATA;
        data_sb = sb.data_queue.pop_back();
        data_intf = intf.IDATA;
        opcode = instruction_sb.opcode.opcode;

        // Print information about the fetched instructions
        `PRINT_INFO(`MONITOR_NAME, $sformatf("Instruction from Scoreboard: 0x%0h", instruction_sb))
        `PRINT_INFO(`MONITOR_NAME, $sformatf("Instruction from Interface: 0x%0h", instruction_intf))

        // Compare instructions from the scoreboard and the DUT
        if (instruction_sb === instruction_intf) begin
          `PRINT_INFO(`MONITOR_NAME, "Scoreboard and interface instructions match")
          pass_counter++;
        end
        else begin
          `PRINT_ERROR(`MONITOR_NAME, "Scoreboard and interface instructions mismatch")
          error_counter++;
        end

        // Check the instruction type and call respective check functions
        `PRINT_INFO(`MONITOR_NAME, $sformatf("Instruction of type \"%s\"", opcode.name()))

        if (opcode == b_type) begin
          // Specialized check for B-type instructions
          check_b_type();
        end
        else if (opcode == i_type) begin
          // Specialized check for I-type instructions
          check_i_type();
        end
        else if (opcode == j_type) begin
          // Specialized check for J-type instructions
          check_j_type();
        end
        else if (opcode == r_type) begin
          // Specialized check for R-type instructions
          check_r_type();
        end
        else if (opcode == s_type) begin
          // Specialized check for S-type instructions
          check_s_type();
        end
        else if (opcode == u_type) begin
          // Specialized check for U-type instructions
          check_u_type();
        end
        else begin
          `PRINT_WARNING(`MONITOR_NAME, $sformatf("Instruction type \"%s\" is not supported", opcode))
        end

        $display();

        // Compare the data input from the scoreboard and the interface
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

  //###############################################################################################
  // Task: check_b_type
  // Description: Specialized check for B-type instructions. This task is called when a B-type
  //              instruction is detected.
  //
  //              B-type instructions include conditional branches such as BEQ (branch if equal),
  //              BNE (branch if not equal), etc.
  // 
  // Example: B-type instructions are used for conditional branching based on register comparisons
  //          in RISC-V architectures.
  //
  //###############################################################################################
  task check_b_type();
    `PRINT_INFO(`MONITOR_NAME, "Checking \"b_type\" instruction")
  endtask : check_b_type

  //###############################################################################################
  // Task: check_i_type
  // Description: Specialized check for I-type instructions. This task is called when an I-type
  //              instruction is detected.
  //
  // Example: I-type instructions include ADDI, XORI, ORI, etc.
  //###############################################################################################
  task check_i_type();
    `PRINT_INFO(`MONITOR_NAME, "Checking \"i_type\" instruction")
  endtask : check_i_type

  //###############################################################################################
  // Task: check_j_type
  // Description: Specialized check for J-type instructions. This task is called when a J-type
  //              instruction is detected.
  //
  //              J-type instructions are used for jump operations, which typically alter the flow
  //              of execution by jumping to a specified address. The most common J-type
  //              instruction in RISC-V is JAL (Jump and Link), which jumps to a target address and
  //              saves the return address in a register.
  //
  // Example: J-type instructions can be utilized for function calls and for implementing control
  //          flow in programs.
  //
  //###############################################################################################
  task check_j_type();
    `PRINT_INFO(`MONITOR_NAME, "Checking \"j_type\" instruction")
  endtask : check_j_type

  //###############################################################################################
  // Task: check_r_type
  // Description: Specialized check for R-type instructions. This task is called when an R-type
  //              instruction is detected.
  //
  // Example: R-type instructions include ADD, SUB, AND, etc.
  //###############################################################################################
  task check_r_type();
    `PRINT_INFO(`MONITOR_NAME, "Checking \"r_type\" instruction")
  endtask : check_r_type

  //###############################################################################################
  // Task: check_s_type
  // Description: Specialized check for S-type instructions. This task is called when an S-type
  //              instruction is detected.
  //
  //              S-type instructions are typically used for store operations, such as storing a
  //              a register value to memory. These instructions include store commands like SW
  //              (store word), SH (store halfword), and SB (store byte).
  //
  // Example: S-type instructions calculate a memory address from a base register and an immediate
  //          value, then store a value from a source register to that address.
  //###############################################################################################
  task check_s_type();
    `PRINT_INFO(`MONITOR_NAME, "Checking \"s_type\" instruction")
  endtask : check_s_type

  //###############################################################################################
  // Task: check_u_type
  // Description: Specialized check for U-type instructions. This task is called when a U-type
  //              instruction is detected.
  //
  //              U-type instructions are used for operations that require a 20-bit immediate value
  //              that is sign-extended to 32 bits. The most common U-type instructions in RISC-V
  //              are LUI (Load Upper Immediate) and AUIPC (Add Upper Immediate to PC).
  //
  // Example: U-type instructions are often used to set up immediate values in higher-order bits,
  //          which can then be combined with lower order bits using other instructions for address
  //          calculations.
  //
  //###############################################################################################
  task check_u_type();
    `PRINT_INFO(`MONITOR_NAME, "Checking \"u_type\" instruction")
  endtask : check_u_type
endclass : monitor
