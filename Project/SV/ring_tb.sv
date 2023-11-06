`timescale 1ns / 1ps
module tb ();

   logic [1:0] count_out;      
   logic       clk;
   logic       reset;
   
  // instantiate device under test
   ring_counter dut (clk, reset, count_out);   

   // 20 ns clock
   initial 
     begin	
	clk = 1'b1;
	forever #10 clk = ~clk;
     end


   initial
     begin    
	#0   reset = 1'b1;
	#43  reset = 1'b0;	
     end

   
endmodule
