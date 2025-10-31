//clock generation block
class clock;
  virtual signal_intf intf;
  function new(virtual signal_intf intf);
    this.intf=intf;
  endfunction
  task clk_gen();
    $display("Clock generated");
    forever #5 intf.clk=~intf.clk;
  endtask
endclass
