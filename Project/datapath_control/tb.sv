`timescale 1ns / 1ps
module tb ();

   logic [7:0] a;
   logic       sel;
   logic       clk;
   logic       reset;
   logic [7:0] z;
   
  // instantiate device under test
   top dut (a, sel, clk, reset, z);

   // 20 ns clock
   initial 
     begin	
	clk = 1'b1;
	forever #10 clk = ~clk;
     end

   // 20 ns clock
   initial 
     begin	
	a = 8'h0;
	forever #15 a = $random;
     end

   initial
     begin
	#0  reset = 1'b1;
	#0  sel = 1'b0;
	#22 reset = 1'b0;
	#71 sel = 1'b1;		
     end

   
endmodule
