module stimulus;

   logic [7:0]  A, B;
   logic 	Cin;
   logic 	Clk;
   
   logic [7:0] 	Sum;
   
   integer handle3;  
   integer desc3;
   
   logic [7:0] answer;   

   rca8 dut (Sum, A, B, Cin);   
  
   initial 
     begin	
        Clk = 1'b1;
        forever #10 Clk = ~Clk;  
     end

   initial
     begin
	#0   Cin = 1'b0;	
	#0   A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;	

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;	

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  Cin = 1'b1;	
	#0   A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;
	#0   answer = A + B + Cin;		

	#20  A = $random;
	#0   B = $random;		
	#0   answer = A + B + Cin;		
     end

endmodule // stimulus
