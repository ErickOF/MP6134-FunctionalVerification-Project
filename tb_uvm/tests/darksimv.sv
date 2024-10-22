import uvm_pkg::*;
import instructions_pkg::*;

`timescale 1ns / 1ps
`include "config.vh"
`include "helper.sv"
`include "darkriscv_input_item.sv"
`include "darkriscv_output_item.sv"
`include "darkriscv_item.sv"
`include "darkriscv_seq.sv"
`include "init_registers_seq.sv"
`include "save_registers_seq.sv"
`include "random_instr_seq.sv"
`include "darkriscv_driver.sv"
`include "darkriscv_monitor.sv"
`include "darkriscv_scoreboard.sv"
`include "darkriscv_agent.sv"
`include "darkriscv_reference_model.sv"
`include "darkriscv_env.sv"
`include "random_instr_test.sv"
`include "darkriscv_test.sv"

module darksimv();
    bit CLK = 0;
    

    darkriscv_if cpu_if(.CLK(CLK));

    initial while(1) #(500e6/`BOARD_CK) CLK = !CLK; // clock generator w/ freq defined by config.vh

    integer i;

    initial
    begin
        $dumpfile("darksocv.vcd");
        $dumpvars();

    `ifdef __REGDUMP__
        for(i = 0; i != `RLEN; i = i+1) begin
            $dumpvars(0, core0.REGS[i]);
        end
    `endif
    end

    darkriscv
    #(
        .CPTR(0)
    )
    core0
    (
        .CLK    (cpu_if.CLK),
        .RES    (cpu_if.RES),
        .HLT    (cpu_if.HLT),

`ifdef __INTERRUPT__
        .IRQ    (cpu_if.IRQ),
`endif

        .IDATA  (cpu_if.IDATA),
        .IADDR  (cpu_if.IADDR),
        .DADDR  (cpu_if.DADDR),

        .DATAI  (cpu_if.DATAI),
        .DATAO  (cpu_if.DATAO),
        .DLEN   (cpu_if.DLEN),
        .DRW    (cpu_if.DRW),
        .DWR    (cpu_if.DWR),
        .DRD    (cpu_if.DRD),
        .DAS    (cpu_if.DAS),

`ifdef SIMULATION
        .ESIMREQ(cpu_if.ESIMREQ),
        .ESIMACK(cpu_if.ESIMACK),
`endif

        .DEBUG  (cpu_if.DEBUG)
    );
  initial begin
    uvm_config_db #(virtual darkriscv_if)::set(null, "", "VIRTUAL_INTERFACE", cpu_if);
    run_test();
  end
endmodule : darksimv
