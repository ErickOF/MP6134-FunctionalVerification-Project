interface darksimv_hvl_proxy(input CLK);

  // Drive
  import "DPI-C" context task c_drive(
      logic [31:0] _IDATA,
      logic [31:0] _DATAI
    );
  import "DPI-C" context task c_reset();

  // Monitor
  import "DPI-C" context task c_mon_sigs(
      output logic [31:0] _IDATA,
      output logic [31:0] _IADDR,
      output logic [31:0] _DATAI,
      output logic [31:0] _DATAO,
      output logic [31:0] _DADDR,
      output logic [2:0]  _DLEN,
      output logic        _DRD,
      output logic        _DWR,
      output bit          _valid
    );

  task xtor_drive(
      logic [31:0] _IDATA,
      logic [31:0] _DATAI
    );
    c_drive(._IDATA(_IDATA), ._DATAI(_DATAI));
  endtask : xtor_drive

  task xtor_reset();
    c_reset();
  endtask : xtor_reset

  task xtor_mon_sigs(
      output logic [31:0] _IDATA,
      output logic [31:0] _IADDR,
      output logic [31:0] _DATAI,
      output logic [31:0] _DATAO,
      output logic [31:0] _DADDR,
      output logic [2:0]  _DLEN,
      output logic        _DRD,
      output logic        _DWR,
      output bit          _valid
    );
    c_mon_sigs(
        ._IDATA(_IDATA),
        ._IADDR(_IADDR),
        ._DATAI(_DATAI),
        ._DATAO(_DATAO),
        ._DADDR(_DADDR),
        ._DLEN(_DLEN),
        ._DRD(_DRD),
        ._DWR(_DWR),
        ._valid(_valid)
      );
  endtask : xtor_mon_sigs

endinterface : darksimv_hvl_proxy
