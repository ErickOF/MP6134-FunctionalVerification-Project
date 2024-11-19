
class darkriscv_input_cov extends uvm_subscriber #(darkriscv_input_item);
  `uvm_component_utils(darkriscv_input_cov)
  darkriscv_input_item current_pkt;

  covergroup cg_input_inst;
    inst_type: coverpoint current_pkt.instruction_data[6:0] {
        bins values[] = {7'b011_0011, 7'b001_0011, 7'b010_0011, 7'b110_0011, 7'b001_0111, 7'b110_1111, 7'b000_1011};
    }
    rd: coverpoint current_pkt.instruction_data[11:7] iff (current_pkt.instruction_data[5:0] != 6'b10_0011); // Not accounting for S or B
    rs1: coverpoint current_pkt.instruction_data[19:15] iff (current_pkt.instruction_data[6:0] != 7'b001_0111 || current_pkt.instruction_data[6:0] != 7'b110_1111); // Not accounting for U or J
    rs2: coverpoint current_pkt.instruction_data[24:20] iff (current_pkt.instruction_data[6:0] != 7'b001_0111 || current_pkt.instruction_data[6:0] != 7'b110_1111 || current_pkt.instruction_data[6:0] != 7'b001_0011); // Not accounting for I, U or J
    funct3: coverpoint current_pkt.instruction_data[14:12] iff (current_pkt.instruction_data[6:0] != 7'b001_0111 || current_pkt.instruction_data[6:0] != 7'b110_1111); // Not accounting for U or J
    funct7: coverpoint current_pkt.instruction_data[31:25] iff (current_pkt.instruction_data[6:0] == 7'b011_0011) {
      bins valids[] = {8'h00, 8'h20};
    }
  endgroup

  function new(string name = "darkriscv_input_cov", uvm_component parent = null);
    super.new(name, parent);
    cg_input_inst = new();
  endfunction

  virtual function void write(darkriscv_input_item pkt);
    this.current_pkt = pkt;
    cg_input_inst.sample();
  endfunction

endclass
