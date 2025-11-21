`timescale 1ns/1ps

`define START_TESTBENCH error_o = 0; pass_o = 0; #10;
`define FINISH_WITH_FAIL error_o = 1; pass_o = 0; #10; $finish();
`define FINISH_WITH_PASS pass_o = 1; error_o = 0; #10; $finish();
module testbench
  // You don't usually have ports in a testbench, but we need these to
  // signal to cocotb/gradescope that the testbench has passed, or failed.
  (output logic error_o = 1'bx
  ,output logic pass_o = 1'bx);

   localparam width_lp = 8;
   logic [width_lp-1:-4] a_i;
   logic [width_lp-1:0] b_i;
   logic [2 * width_lp - 1  :-4] product_o;

   // You can use this 
   logic [0:0] error;
   
   integer i, j;
   logic [2*width_lp-1:0] expected;

   // Deterministic test vectors
   logic [width_lp-1:0] test_vals [0:19];

   initial begin
      `START_TESTBENCH

      // Fill test_vals with some deterministic values
      test_vals[0]  = 0;
      test_vals[1]  = 1;
      test_vals[2]  = 2;
      test_vals[3]  = 3;
      test_vals[4]  = 4;
      test_vals[5]  = 5;
      test_vals[6]  = 7;
      test_vals[7]  = 15;
      test_vals[8]  = 31;
      test_vals[9]  = 63;
      test_vals[10] = 127;
      test_vals[11] = 255;
      test_vals[12] = 511;
      test_vals[13] = 1023;
      test_vals[14] = 2047;
      test_vals[15] = 4095;
      test_vals[16] = 8191;
      test_vals[17] = 16383;
      test_vals[18] = 32767;
      test_vals[19] = 65535;

      // Exhaustive deterministic test
      for (i = 0; i < 20; i = i + 1) begin
         for (j = 0; j < 20; j = j + 1) begin
            a_i = test_vals[i];
            b_i = test_vals[j];
            #1; // wait for DUT

            expected = a_i * b_i;

            if (product_o !== expected) begin
               $display("FAIL: a=%0d b=%0d DUT=%0d Expected=%0d", a_i, b_i, product_o, expected);
               `FINISH_WITH_FAIL
            end else begin
               $display("PASS: a=%0d b=%0d DUT=%0d", a_i, b_i, product_o);
            end
         end
      end

      // All tests passed
      `FINISH_WITH_PASS
   end
   // This block executes after $finish() has been called.
   final begin
      $display("Simulation time is %t", $time);
      if(error_o === 1) begin
	 $display("\033[0;31m    ______                    \033[0m");
	 $display("\033[0;31m   / ____/_____________  _____\033[0m");
	 $display("\033[0;31m  / __/ / ___/ ___/ __ \\/ ___/\033[0m");
	 $display("\033[0;31m / /___/ /  / /  / /_/ / /    \033[0m");
	 $display("\033[0;31m/_____/_/  /_/   \\____/_/     \033[0m");
	 $display("Simulation Failed");
     end else if (pass_o === 1) begin
	 $display("\033[0;32m    ____  ___   __________\033[0m");
	 $display("\033[0;32m   / __ \\/   | / ___/ ___/\033[0m");
	 $display("\033[0;32m  / /_/ / /| | \\__ \\\__ \ \033[0m");
	 $display("\033[0;32m / ____/ ___ |___/ /__/ / \033[0m");
	 $display("\033[0;32m/_/   /_/  |_/____/____/  \033[0m");
	 $display();
	 $display("Simulation Succeeded!");
     end else begin
        $display("   __  ___   ____ __ _   ______ _       ___   __");
        $display("  / / / / | / / //_// | / / __ \\ |     / / | / /");
        $display(" / / / /  |/ / ,<  /  |/ / / / / | /| / /  |/ / ");
        $display("/ /_/ / /|  / /| |/ /|  / /_/ /| |/ |/ / /|  /  ");
        $display("\\____/_/ |_/_/ |_/_/ |_/\\____/ |__/|__/_/ |_/   ");
	$display("Please set error_o or pass_o!");
     end
   end

endmodule
