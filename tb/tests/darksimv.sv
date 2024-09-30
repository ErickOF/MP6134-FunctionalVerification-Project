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
`include "config.vh"
`include "stimulus_types.sv"
`include "stimulus.sv"
`include "scoreboard.sv"
`include "driver.sv"
`include "monitor.sv"
`include "environment.sv"
`include "test.sv"

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
        @(negedge RES);
        @(posedge CLK);
        cpu_if.HLT <= 1'b1;
`ifdef __INTERRUPT__
        cpu_if.IRQ <= 1'b1;
`endif
    end

    initial
    begin
        @(posedge CLK);
        cpu_if.HLT <= 1'b0;
`ifdef __INTERRUPT__
        cpu_if.IRQ <= 1'b0;
`endif
        cpu_if.IDATA <= 32'h0;
        cpu_if.DATAI <= 32'h0;
`ifdef SIMULATION
        cpu_if.ESIMREQ <= 1'b0;
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

    // Test program execution
    // Invoke the test case with the virtual interface
    test testcase(cpu_if);
endmodule
