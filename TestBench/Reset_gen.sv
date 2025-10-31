// reset generation block
class reset;
  virtual signal_intf intf;
  function new(virtual signal_intf intf);
    this.intf=intf;
  endfunction
  task rst_gen();
    $display("Reset generated");
    @(posedge intf.clk or negedge intf.clk)begin
    //@(posedge clk or negedge clk)begin
      #20 intf.reset_n=1'b1;
    end
  endtask
endclass
