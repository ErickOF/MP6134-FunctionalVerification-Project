`ifndef HELPER_SV
`define HELPER_SV

//#################################################################################################
// File: helper.sv
// Description: A set of macros to enhance output messages in simulation logs. These macros utilize
//              ANSI escape codes to provide colored outputs for different types of messages (INFO,
//              WARNING, ERROR, FATAL), making it easier to distinguish between various report
//              types in the console.
//
// ANSI Escape Codes for Colors:
// -- Used to print colored text in the terminal, providing visual cues for different message
//    types. The color is reset after the message to avoid affecting subsequent outputs.
//
//    COLOR_RESET: Resets terminal text color to default
//    COLOR_INFO: Prints text in green, used for informational messages
//    COLOR_WARNING: Prints text in yellow, used for warnings
//    COLOR_ERROR: Prints text in red, used for errors
//    COLOR_FATAL: Prints text in magenta, used for fatal errors
//
// Macros:
// -- PRINT(COLOR, ID_MSG, TYPE, MSG):
//    Prints a message to the console with the specified color, message type, source file, line
//    number, simulation time, and additional message info.
//    * COLOR: Color code for the message
//    * ID_MSG: Identifier message or component name (e.g., module name)
//    * TYPE: Type of message (INFO, WARNING, ERROR, FATAL)
//    * MSG: The actual message to display
//
// -- PRINT_INFO(ID_MSG, MSG): Prints an INFO message with green color.
// -- PRINT_WARNING(ID_MSG, MSG): Prints a WARNING message with yellow color.
// -- PRINT_ERROR(ID_MSG, MSG): Prints an ERROR message with red color.
// -- PRINT_FATAL(ID_MSG, MSG): Prints a FATAL message with magenta color and terminates the
//    simulation using $fatal.
//#################################################################################################

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

//#################################################################################################
// Macro: PRINT
// Description: Prints a formatted message with color, type, file, line number, time, ID, and
//              message details. Helps in categorizing log messages for easier debugging.
//#################################################################################################
`define PRINT(COLOR, ID_MSG, TYPE, MSG) \
  $display("%s%s %s (%0d) @ %0t: report [%s] %s%s", COLOR, TYPE, `__FILE__, `__LINE__, $time, ID_MSG, MSG, `COLOR_RESET);

// Macros for specific message types
// -- Info message with green color
`define PRINT_INFO(ID_MSG, MSG) `PRINT(`COLOR_INFO, ID_MSG, "INFO", MSG)
// -- Warning message with yellow color
`define PRINT_WARNING(ID_MSG, MSG) `PRINT(`COLOR_WARNING, ID_MSG, "WARNING", MSG)
// -- Error message with red color
`define PRINT_ERROR(ID_MSG, MSG) `PRINT(`COLOR_ERROR, ID_MSG, "ERROR", MSG)
// -- Fatal message with magenta color; ends simulation with $fatal
`define PRINT_FATAL(ID_MSG, MSG) `PRINT(`COLOR_FATAL, ID_MSG, "FATAL", MSG) $fatal;

`endif // HELPER_SV
