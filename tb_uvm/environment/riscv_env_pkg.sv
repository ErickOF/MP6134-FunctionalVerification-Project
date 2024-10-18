`ifndef _RISCV_ENV_PKG_SV_
`define _RISCV_ENV_PKG_SV_

package riscv_env_pkg;

  import uvm_pkg::*;

  import riscv_instructions_pkg::*;

  import riscv_items_pkg::*;

  `include "riscv_scoreboard.svh"
  `include "riscv_reference_model.svh"
  `include "riscv_env.svh";

endpackage : riscv_env_pkg

`endif // _RISCV_ENV_PKG_SV_