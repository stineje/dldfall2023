`timescale 1ns / 1ps
module tb ();

   logic       clk;   
   logic       rst;
   logic       clk_en;      
   
   integer     handle3;  
   integer 	 desc3;    

   // instantiate device under test   
   clk_div dut (clk, rst, clk_en);

   // 2 ns clock
   initial 
     begin	
	clk = 1'b1;
	forever #10 clk = ~clk;
     end

   // Give reset signal for clock enable
   initial
     begin
	// Initialization of board (X is going)
	#0   rst = 1'b1;
	#100 rst = 1'b0;

     end
   
endmodule // tb

