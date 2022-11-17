module register(clk, seed, seed_out);
   
   input logic [63:0] seed;
   input logic 	      clk;
   output logic [63:0] seed_out;
   
   always @ (posedge clk)
     begin
	seed_out <= seed;
     end
   
endmodule // register
