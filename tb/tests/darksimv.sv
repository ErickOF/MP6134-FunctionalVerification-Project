/*
 * Copyright (c) 2018, Marcelo Samsoniuk
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

`timescale 1ns / 1ps
`include "../../rtl/src/config.vh"

// clock and reset logic

module darksimv;

    bit CLK = 0;
    
    bit RES = 1;

    darkriscv_if cpu_if(.CLK(CLK), .RES(RES));

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
        $display("reset (startup)");
        #1e3    RES = 0;            // wait 1us in reset state
        $display("reset finished");
        #1e3;
        $display("Finished simulation");
        $finish;
    end

    initial
    begin
        @(posedge CLK);
        cpu_if.CPU.HLT <= 1'b1;
`ifdef __INTERRUPT__
        cpu_if.CPU.IRQ <= 1'b1;
`endif
        cpu_if.CPU.IDATA <= 32'h0;
        cpu_if.CPU.DATAI <= 32'h0;
`ifdef SIMULATION
        cpu_if.CPU.ESIMREQ <= 1'b0;
`endif
    end

    darkriscv
    #(
        .CPTR(0)
    )
    core0
    (
        .CLK    (cpu_if.CPU.CLK),
        .RES    (cpu_if.CPU.RES),
        .HLT    (cpu_if.CPU.HLT),

`ifdef __INTERRUPT__
        .IRQ    (cpu_if.CPU.IRQ),
`endif

        .IDATA  (cpu_if.CPU.IDATA),
        .IADDR  (cpu_if.CPU.IADDR),
        .DADDR  (cpu_if.CPU.DADDR),

        .DATAI  (cpu_if.CPU.DATAI),
        .DATAO  (cpu_if.CPU.DATAO),
        .DLEN   (cpu_if.CPU.DLEN),
        .DRW    (cpu_if.CPU.DRW),
        .DWR    (cpu_if.CPU.DWR),
        .DRD    (cpu_if.CPU.DRD),
        .DAS    (cpu_if.CPU.DAS),

`ifdef SIMULATION
        .ESIMREQ(cpu_if.CPU.ESIMREQ),
        .ESIMACK(cpu_if.CPU.ESIMACK),
`endif

        .DEBUG  (cpu_if.CPU.DEBUG)
    );

endmodule
