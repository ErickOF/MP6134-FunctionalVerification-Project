`ifndef __RISCV_DEFS_SVH__
`define __RISCV_DEFS_SVH__

typedef bit [31:0] riscv_instruction_d;

`define RISCV_INST_OPCODE_RANGE       6:0
`define RISCV_INST_RD_RANGE           11:7
`define RISCV_INST_FUNC3_RANGE        14:12
`define RISCV_INST_RS1_RANGE          19:15
`define RISCV_INST_RS2_RANGE          24:20
`define RISCV_INST_IMM_I_11_0_RANGE   31:20
`define RISCV_INST_IMM_S_11_5_RANGE   31:25
`define RISCV_INST_IMM_S_4_0_RANGE    11:7

`endif // __RISCV_DEFS_SVH__
