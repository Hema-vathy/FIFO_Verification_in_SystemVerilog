///////************DESIGN CODE FOR THE FIFO************///////
module fifo #(
  parameter DATA_WIDTH = 16,      // Data width
  parameter DEPTH = 8,            // FIFO depth
  parameter ADDR_WIDTH = 3        // Address width (log2(DEPTH))
)(
  input logic clk,                // System clock
  input logic reset_n,            // Active-low synchronous reset
  input logic write_en,           // Write enable
  input logic read_en,            // Read enable
  input logic [DATA_WIDTH-1:0] data_in,  // Data input bus
  output logic [DATA_WIDTH-1:0] data_out, // Data output bus
  output logic full,              // Full flag
  output logic empty,             // Empty flag
  output logic almost_full,       // Almost full flag
  output logic almost_empty,      // Almost empty flag
  output logic overflow,          // Overflow flag
  output logic underflow          // Underflow flag
);

  // Internal signals
  logic [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1]; // FIFO memory
  logic [ADDR_WIDTH-1:0] write_ptr, read_ptr;  // Write and read pointers
  logic [ADDR_WIDTH:0] count;                  // Counter for number of elements in FIFO

  // Synchronous reset and pointer management
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      write_ptr <= 0;
      read_ptr <= 0;
      count <= 0;
      full <= 0;
      empty <= 1;
      almost_full <= 0;
      almost_empty <= 1;
      overflow <= 0;
      underflow <= 0;
    end else begin
      // Handle write operation
      if (write_en && !full) begin
        fifo_mem[write_ptr] <= data_in;
        write_ptr <= (write_ptr + 1) % DEPTH;
        count <= count + 1;
        overflow <= 0;
      end else if (write_en && full) begin
        overflow <= 1; // Overflow condition
      end

      // Handle read operation
      if (read_en && !empty) begin
        data_out <= fifo_mem[read_ptr];
        read_ptr <= (read_ptr + 1) % DEPTH;
        count <= count - 1;
        underflow <= 0;
      end else if (read_en && empty) begin
        underflow <= 1; // Underflow condition
      end

      // Flag management
      full <= (count == DEPTH);
      empty <= (count == 0);
      almost_full <= (count >= DEPTH - 1);
      almost_empty <= (count <= 1);
    end
  end

endmodule
