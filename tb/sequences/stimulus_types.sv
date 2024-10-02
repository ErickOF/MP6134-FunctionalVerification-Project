typedef enum logic [6:0] {
  r_type = 7'b011_0011,
  i_type = 7'b001_0011, //TODO: only for: ADDI, XORI, ORI, ANDI, SLLI, SRLI, SRAI, SLTI and SLTIU
  s_type = 7'b010_0011,
  b_type = 7'b110_0011,
  u_type = 7'b001_0111, //TODO: only for AUIPC
  j_type = 7'b110_1111 //TODO: only for JAL
} inst_type_e;

typedef enum logic [2:0] {
  addi      = 3'b000,
  slli      = 3'b001,
  slti      = 3'b010,
  sltiu     = 3'b011,
  xori      = 3'b100,
  srli_srai = 3'b101,
  ori       = 3'b110,
  andi      = 3'b111
} func3_i_type_e;
