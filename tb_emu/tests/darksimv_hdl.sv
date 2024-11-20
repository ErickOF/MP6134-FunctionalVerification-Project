import uvm_pkg::*;

module darksimv_hdl();
    bit CLK = 1'b0;

    darksimv_hdl_xtor cpu_if(.CLK(CLK));

    // clock generator w/ freq defined by config.vh
    initial while(1) #(500e6/`BOARD_CK) CLK = !CLK;

    integer i;

    initial
    begin
        $dumpfile("darksocv.vcd");
        $dumpvars();

    `ifdef __REGDUMP__
        for(i = 0; i != `RLEN; i = i + 1) begin
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

    r_type_assertions i_r_type_assertions(cpu_if);

    initial begin
        uvm_config_db #(virtual darksimv_hdl_xtor)::set(null, "", "VIRTUAL_INTERFACE", cpu_if);
    end
endmodule : darksimv_hdl
