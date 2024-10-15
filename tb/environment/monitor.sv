// Based on: https://www.edaplayground.com/x/Yk4N
class monitor;
  // Reference to the scoreboard to fetch expected values
  scoreboard sb_in;
  scoreboard sb_write;

  // Virtual interface to observe signals from the DUT
  virtual darkriscv_if intf;

  mailbox #(riscv_instruction_d) mb_mn_instr;

  // Constructor: Initializes the interface and scoreboard objects
  function new(virtual darkriscv_if intf, scoreboard sb_in, scoreboard sb_write, mailbox #(riscv_instruction_d) mb_mn_instr);
    this.intf = intf;
    this.sb_in = sb_in;
    this.sb_write = sb_write;
    this.mb_mn_instr = mb_mn_instr;
  endfunction : new

  // Check task: Continuously monitors the read enable signal and checks the data output
  task check();
    logic [31:0] instruction_data;
    logic [31:0] input_data;

    logic write_op;
    logic read_op;
    logic [31:0] data_address;
    logic [31:0] output_data;
    logic [2:0] bytes_transfered;

    inst_type_e opcode;

    forever begin
      @ (negedge intf.CLK);
      if (!intf.HLT && !intf.RES) begin
        instruction_data = intf.IDATA;
        input_data = intf.DATAI;
        opcode = instruction_data[`RISCV_INST_OPCODE_RANGE];

        if (intf.DWR) begin
          write_op = 1;
          read_op = 0;
          data_address = intf.DADDR;
          output_data = intf.DATAO;
          bytes_transfered = intf.DLEN;
        end
        else if (intf.DRD) begin
          write_op = 0;
          read_op = 1;
          data_address = intf.DADDR;
          bytes_transfered = intf.DLEN;
        end
        else begin
          write_op = 0;
          read_op = 0;
          bytes_transfered = 0;
        end

        if (opcode != custom_0_type) begin
          sb_in.actual_mb[0].put(instruction_data);
          sb_in.actual_mb[1].put(input_data);
        end

        mb_mn_instr.put(riscv_instruction_d'(instruction_data));
        $display("Time: %0t, Instruction IDATA: %h, Input Data: %h", $time, instruction_data, input_data);

        if (write_op) begin
          sb_write.actual_mb[0].put(data_address);
          sb_write.actual_mb[1].put(output_data);
          sb_write.actual_mb[2].put(bytes_transfered);

          $display("Time: %0t, Write operation of %0d bytes: Data Address: %h, Output Data: %h", $time, bytes_transfered, data_address, output_data);
        end
      end
    end
  endtask : check
endclass : monitor
