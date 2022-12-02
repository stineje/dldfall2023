module top (input logic [7:0] a, 
	    input logic        sel, clk, reset,
	    output logic [7:0] z);

   logic [7:0] 		       sum;
   logic [7:0] 		       sub;
   logic [7:0] 		       regin;   

   adder p1 (a, z, sum);
   sub p2 (a, z, sub);
   assign regin = sel ? sub : sum;
   flopr p3 (clk, reset, regin, z);

endmodule // top

