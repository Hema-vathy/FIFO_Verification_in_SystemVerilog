/////////***********TESTBENCH TOP FILE***********/////////
`include "interface.sv"
`include "files.sv"
import pkg::*;

module fifo_tb;
signal_intf intf();

  // Instantiate the FIFO
  fifo fifo_inst (
    .clk(intf.clk),
    .reset_n(intf.reset_n),
    .write_en(intf.write_en),
    .read_en(intf.read_en),
    .data_in(intf.data_in),
    .data_out(intf.data_out),
    .full(intf.full),
    .empty(intf.empty),
    .almost_full(intf.almost_full),
    .almost_empty(intf.almost_empty),
    .overflow(intf.overflow),
    .underflow(intf.underflow)
  );

  // Testbench procedure
  initial begin
    // Initialize signals
    intf.clk = 0;
    intf.reset_n = 0;
    intf.write_en = 0;
    intf.read_en = 0;
    intf.data_in = 0;
    intf.data_out_check = 0;
    intf.error_count=0;
  end
  initial begin
    run_block run_block_h = new(intf);
    run_block_h.run();
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
endmodule
