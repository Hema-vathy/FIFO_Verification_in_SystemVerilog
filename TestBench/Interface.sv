//////////*************INTERFACE FILE - CONTAINS ALL THE SIGNALS NEEDED FOR THE VERIFICATION*************//////////
interface signal_intf #(
  parameter DATA_WIDTH = 16,
  parameter DEPTH = 8,
  parameter ADDR_WIDTH = 3
);

  // Signals
  logic clk;
  logic reset_n;
  logic write_en;
  logic read_en;
  logic [DATA_WIDTH-1:0] data_in;
  logic [DATA_WIDTH-1:0] data_out;
  logic [DATA_WIDTH-1:0] data_out_check;
  logic full;
  logic empty;
  logic almost_full;
  logic almost_empty;
  logic overflow;
  logic underflow;
  logic error_count;
  
endinterface
