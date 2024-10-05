`ifndef HELP_SV
`define HELP_SV

// ANSI escape codes for colors
// -- Normal color
`define COLOR_RESET "\033[0m"
// -- Green color
`define COLOR_INFO "\033[32m"
// -- Yellow color
`define COLOR_WARNING "\033[33m"
// -- Red color
`define COLOR_ERROR "\033[31m"
// -- Magenta color
`define COLOR_FATAL "\033[35m"

`define PRINT(COLOR, ID_MSG, TYPE, MSG) \
  $display("%s%s %s (%0d) @ %0t: report [%s] %s%s", COLOR, TYPE, `__FILE__, `__LINE__, $time, ID_MSG, MSG, `COLOR_RESET);

`define PRINT_INFO(ID_MSG, MSG) `PRINT(`COLOR_INFO, ID_MSG, "INFO", MSG)
`define PRINT_WARNING(ID_MSG, MSG) `PRINT(`COLOR_WARNING, ID_MSG, "WARNING", MSG)
`define PRINT_ERROR(ID_MSG, MSG) `PRINT(`COLOR_ERROR, ID_MSG, "ERROR", MSG)
`define PRINT_FATAL(ID_MSG, MSG) `PRINT(`COLOR_FATAL, ID_MSG, "FATAL", MSG) $fatal;

`endif // HELP_SV
