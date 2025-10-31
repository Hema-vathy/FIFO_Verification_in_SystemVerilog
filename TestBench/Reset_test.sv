//reset test
class resettest;
  virtual signal_intf intf;
  function new(virtual signal_intf intf);
    this.intf=intf;
  endfunction
  task reset_test();
    $display("Reset Test is started");
    #10 intf.rst=1'b1;
    #10 intf.rst=1'b0;
    if (!intf.empty) $fatal("Simultaneous Read/Write While Empty Test: FIFO should be empty after reset");
  endtask
endclass
