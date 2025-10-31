//////////////***********BASIC TESTS FILE***********//////////////
class test;
  virtual signal_intf intf;
  function new(virtual signal_intf intf);
    this.intf=intf;
  endfunction
  
  //handle for reset_gen
  //calling tasks
  // Basic write and read test
  task call();
    reset_test();
    
    basic_write_read_test();

    // Underflow test
    underflow_test();

    // Overflow test
    overflow_test();

    // Simultaneous Read/Write tests:
    simultaneous_read_write_empty_test();
    simultaneous_read_write_full_test();
    error_counting();
    $finish;
  endtask
  
    task basic_write_read_test();
    begin
      // Write values from 0 to DEPTH-1
      for (int i = 0; i < intf.DEPTH; i++) begin
        intf.write_en = 1;
        intf.data_in = i;
        $display("data_in[%d]=%d",i,intf.data_in);
        #10;
        intf.write_en = 0;
        #10;
      end

      // Check full flag
      if (!intf.full) begin
        $error("Basic Write/Read Test: FIFO should be full");
        intf.error_count++;
      end

      // Read values back and verify
      for (int i = 0; i <intf.DEPTH; i++) begin
        intf.read_en = 1;
        #10;
        intf.read_en = 0;
        $display("data_out[%d]=%d",i,intf.data_out);
        if (intf.data_out != i) begin
          $error("Basic Write/Read Test: Data mismatch at index %0d: expected %0d, got %0d", i, i, intf.data_out);
          intf.error_count++;
        end
        #10;
      end

      // Check empty flag
      if (!intf.empty) begin
        $error("Basic Write/Read Test: FIFO should be empty");
        intf.error_count++;
      end

      // Check overflow and underflow flags
      if (intf.overflow) begin
        $error("Basic Write/Read Test: FIFO should not overflow");
        intf.error_count++;
      end
      if (intf.underflow) begin
        $error("Basic Write/Read Test: FIFO should not underflow");
        intf.error_count++;
      end
    end
  endtask

  // Task for underflow test
  task underflow_test();
    begin
      intf.data_out_check = intf.data_out;
      // Load a single value
      intf.write_en = 1;
      intf.data_in = 16'hA5A5;
      #10;
      intf.write_en = 0;
      #10;
      
      reset_test();

      // Attempt to read while empty
      intf.read_en = 1;
      #10;
      intf.read_en = 0;
      if (!intf.underflow) begin
        $error("Underflow Test: Underflow flag should be asserted");
        intf.error_count++;
      end
      if (intf.data_out != intf.data_out_check) begin
        $error("Underflow Test: Data out should be unchanged from last read value when underflow occurs.");
        intf.error_count++;
      end
      //else $warning("Read Data %0d", data_out);
    end
  endtask

  // Task for overflow test
  task overflow_test();
    begin
      // Fill the FIFO completely
      for (int i = 0; i < intf.DEPTH; i++) begin
        intf.write_en = 1;
        intf.data_in = i;
        #10;
        intf.write_en = 0;
        #10;
      end

      // Attempt to write additional data
      intf.write_en = 1;
      intf.data_in = 16'hFFFF;
      #10;
      intf.write_en = 0;
      if (!intf.overflow) begin
        $error("Overflow Test: Overflow flag should be asserted");
        intf.error_count++;
      end

      // Read out all values and verify
      for (int i = 0; i < intf.DEPTH; i++) begin
        intf.read_en = 1;
        #10;
        intf.read_en = 0;
        if (intf.data_out != i) begin
          $error("Overflow Test: Data mismatch at index %0d: expected %0d, got %0d", i, i, intf.data_out);
          intf.error_count++;
        end
        #10;
      end

      // Ensure the overflowed value is not in the FIFO
      intf.read_en = 1;
      #10;
      intf.read_en = 0;
      if (!intf.empty) begin
        $error("Overflow Test: FIFO should be empty after reading all values");
        intf.error_count++;
      end
    end
  endtask
  
  // Task for simultaneous read and write while empty test
  task simultaneous_read_write_empty_test();
    begin
      intf.data_out_check = intf.data_out; // grab current output value to check if it changes
      
      reset_test();
      
      // Attempt to write and read simultaneously
      intf.write_en = 1;
      intf.read_en = 1;
      intf.data_in = 16'h1234;
      #10;
      //write_en = 0;
      intf.read_en = 0;
      #10;
      if (intf.data_out != intf.data_out_check) begin
        $error("Simultaneous Read/Write While Empty Test: Data out should be unchanged on first simultaneous read/write");
        intf.error_count++;
      end
      if (!intf.underflow) begin
        $error("Simultaneous Read/Write While Empty Test: Underflow flag should be asserted on first simultaneous read/write");
        intf.error_count++;
      end

      // Verify empty flag clears and almost empty is asserted
      if (intf.empty) begin
        $error("Simultaneous Read/Write While Empty Test: FIFO should not be empty after first write");
        intf.error_count++;
      end
      if (!intf.almost_empty) begin
        $error("Simultaneous Read/Write While Empty Test: FIFO should be almost empty after first write");
        intf.error_count++;
      end

      // Test valid simultaneous read and write
      intf.write_en = 1;
      intf.read_en = 1;
      intf.data_in = 16'h5678;
      #10;
      intf.write_en = 0;
      intf.read_en = 0;
      #10;
      if (intf.data_out != 16'h1234) begin
        $error("Simultaneous Read/Write While Empty Test: Data mismatch on simultaneous read/write: expected 16'h1234, got %0h", intf.data_out);
        intf.error_count++;
      end
      if (intf.empty) begin
        $error("Simultaneous Read/Write While Empty Test: FIFO should not be empty after simultaneous read/write");
        intf.error_count++;
      end
      if (!intf.almost_empty) begin
        $error("Simultaneous Read/Write While Empty Test: FIFO should be almost empty after simultaneous read/write");
        intf.error_count++;
      end
    end
  endtask
  
    // Task for simultaneous read and write While Full test
  task simultaneous_read_write_full_test();
    begin

      reset_test();

      // Write FIFO to full
        intf.write_en = 1;
      for (int i = 0; i < intf.DEPTH ; i++) begin 
          intf.data_in = i;
          #10;
        end

        intf.write_en = 0;
        intf.data_out_check = intf.data_in; 
        #10;
      // Verify full flag is set
      if (!intf.full) $error("Simultaneous Read/Write While Full Test: FIFO should be full");

        // Enable simultaneous read and write
        intf.write_en = 1;
        intf.read_en = 1;
        intf.data_in = 16'h9ABC;
        #10;
        intf.write_en = 0;
        #10;
        
        // check to see if overflow is triggered
      if (!intf.overflow) begin
          $error("Simultaneous Read/Write While Full Test: Overflow flag should be asserted on first simultaneous read/write");
          intf.error_count++;
        end
        
        intf.write_en = 1;
      for (int k = 0; k < intf.DEPTH+5; k++) begin
          #10;
        if (k == intf.DEPTH-3 && intf.data_out != intf.data_out_check) begin 
            $error("Simultaneous Read/Write While Full Test: Data out should be match saved value, %x. Instead a value was written while overflow was asserted: %x.", intf.data_out_check, intf.data_out);
            intf.error_count++;
          end
        else if (k > intf.DEPTH-3 && intf.data_out != intf.data_in) begin
            $error("Simultaneous Read/Write While Full Test: Data out should be match continuous input value, %x, after overflow is cleared and simultaneous read/write is allowed.", intf.data_in);
            intf.error_count++;
          end
        end
        intf.write_en = 0;
        intf.read_en = 0;
        
    end
  endtask
  
  task reset_test();
    $display("Reset Test is started");
    #10 intf.reset_n=1'b0;
    #10 intf.reset_n=1'b1;
    if (!intf.empty) $display("Simultaneous Read/Write While Empty Test: FIFO should be empty after reset");
  endtask
  
  task error_counting();
    if (intf.error_count == 0) begin
      $display("\n!!  All tests completed successfully !!!!! \n");
    end else begin
      $display("Test completed with %0d errors", intf.error_count);
    end
  endtask
endclass
