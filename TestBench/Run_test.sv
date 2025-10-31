// Run block for testbench
class run_block;
virtual signal_intf intf;
  function new(virtual signal_intf intf);
    this.intf=intf;
  endfunction
  
  task run();
    clock clk_generate_h = new(intf);
    reset rst_generate_h = new(intf);
    test test_h = new(intf);
    fork
      clk_generate_h.clk_gen();
      rst_generate_h.rst_gen();
      test_h.call();
    join
  endtask
endclass
