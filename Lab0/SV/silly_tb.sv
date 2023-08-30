`timescale 1ns / 1ps
module tb ();

   logic        a;
   logic 	b;
   logic 	c;
   logic 	y;
   logic        clk;   
   
  // instantiate device under test
   silly dut (a, b, c, y);

   // 2 ns clock
   initial 
     begin	
	clk = 1'b1;
	forever #10 clk = ~clk;
     end


   initial
     begin
    
	#20  a = $random;	
	#0   b = $random;	
	#0   c = $random;

	#20  a = $random;	
	#0   b = $random;	
	#0   c = $random;

	#20  a = $random;	
	#0   b = $random;	
	#0   c = $random;	

	#20  a = $random;	
	#0   b = $random;	
	#0   c = $random;	

	#20  a = $random;	
	#0   b = $random;	
	#0   c = $random;	

	#20  a = $random;	
	#0   b = $random;	
	#0   c = $random;	

	#20  a = $random;	
	#0   b = $random;	
	#0   c = $random;	

	#20  a = $random;	
	#0   b = $random;	
	#0   c = $random;	

	#20  a = $random;	
	#0   b = $random;	
	#0   c = $random;	

	#20  a = $random;	
	#0   b = $random;	
	#0   c = $random;	

	#20  a = $random;	
	#0   b = $random;	
	#0   c = $random;		
	
     end

   
endmodule
